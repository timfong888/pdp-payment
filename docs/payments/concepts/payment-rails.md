# Payment Rails

## Overview

Payment Rails are a core component of the PDP-Payments (FWS) system that enable continuous, programmable payment flows between clients and storage providers. They function as dedicated payment channels that automate the process of compensating storage providers for their services while enforcing Service Level Agreements (SLAs).

## Key Concepts

### What is a Payment Rail?

A Payment Rail is a smart contract-based payment channel that:

1. **Connects two parties**: A payer (client) and a payee (storage provider)
2. **Enables continuous payments**: Funds flow at a specified rate over time
3. **Enforces SLAs**: Integrates with arbiters to adjust payments based on service quality
4. **Provides security**: Locks funds to ensure payment obligations are met
5. **Offers flexibility**: Allows for rate adjustments and termination conditions

### Rail Structure

Each Payment Rail is represented by a data structure with the following components:

```solidity
struct Rail {
    address token;        // ERC20 token used for payments
    address from;         // Payer address
    address to;           // Payee address
    address operator;     // Entity that can modify the rail
    address arbiter;      // Optional arbiter for SLA enforcement
    
    uint256 paymentRate;  // Rate at which payments flow (per epoch)
    uint256 lockupPeriod; // Number of epochs for which funds are locked
    uint256 lockupFixed;  // Fixed amount of funds locked
    
    uint256 settledUpTo;  // Epoch up to which payments have been settled
    uint256 endEpoch;     // Epoch at which the rail terminates
    uint256 commissionRateBps; // Commission rate in basis points
    
    RateChange[] rateChangeQueue; // Queue of scheduled rate changes
}
```

## How Payment Rails Work

### 1. Rail Creation

A Payment Rail is created by calling the `createRail` function in the Payments contract:

```solidity
function createRail(
    address token,
    address from,
    address to,
    address arbiter,
    uint256 paymentRate,
    uint256 lockupPeriod,
    uint256 lockupFixed,
    uint256 commissionRateBps
) external returns (uint256 railId)
```

**Example:**
```javascript
// Create a payment rail with USDC
async function createPaymentRail() {
    // Contract instance
    const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);
    
    // Parameters
    const tokenAddress = '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'; // USDC on testnet
    const clientAddress = wallet.address;
    const providerAddress = '0x123...'; // Storage provider address
    const arbiterAddress = '0x456...'; // Arbiter address
    const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDC per epoch
    const lockupPeriod = 2880; // 1 day in epochs (assuming 30-second epochs)
    const lockupFixed = ethers.utils.parseUnits('5', 6); // 5 USDC fixed lockup
    const commissionRate = 250; // 2.5% commission
    
    // Create the rail
    const tx = await payments.createRail(
        tokenAddress,
        clientAddress,
        providerAddress,
        arbiterAddress,
        paymentRate,
        lockupPeriod,
        lockupFixed,
        commissionRate
    );
    
    const receipt = await tx.wait();
    const railId = receipt.events[0].args.railId;
    
    return railId;
}
```

### 2. Fund Lockup

When a rail is created, funds are locked in the Payments contract to ensure payment obligations:

```javascript
// Before creating a rail, deposit funds
async function depositFunds(tokenAddress, amount) {
    // Approve the Payments contract to spend tokens
    const token = new ethers.Contract(tokenAddress, tokenAbi, wallet);
    await token.approve(paymentsAddress, amount);
    
    // Deposit funds
    const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);
    await payments.deposit(tokenAddress, wallet.address, amount);
}
```

The lockup amount is calculated as:
- Fixed lockup amount (`lockupFixed`)
- Plus the payment rate multiplied by the lockup period (`paymentRate * lockupPeriod`)

### 3. Payment Flow

Payments flow continuously at the specified rate, but are settled discretely:

```javascript
// Settle payments up to the current epoch
async function settlePayments(railId) {
    const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);
    const currentEpoch = await provider.getBlockNumber();
    await payments.settleRail(railId, currentEpoch);
}
```

### 4. Arbitration

If an arbiter is specified, it can adjust payment amounts based on service quality:

```solidity
interface IArbiter {
    struct ArbitrationResult {
        uint256 modifiedAmount; // Adjusted payment amount
        uint256 settleUpto;     // Epoch up to which to settle
        string note;            // Additional information
    }
    
    function arbitratePayment(
        address token,
        address from,
        address to,
        uint256 railId,
        uint256 fromEpoch,
        uint256 toEpoch,
        uint256 amount
    ) external view returns (ArbitrationResult memory);
}
```

**Example Arbiter Implementation:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IArbiter.sol";
import "./IPDPService.sol";

contract PDPArbiter is IArbiter {
    IPDPService public pdpService;
    mapping(uint256 => uint256) public railToProofSet;
    
    constructor(address _pdpService) {
        pdpService = IPDPService(_pdpService);
    }
    
    function registerRailProofSet(uint256 railId, uint256 proofSetId) external {
        // Add appropriate access control here
        railToProofSet[railId] = proofSetId;
    }
    
    function arbitratePayment(
        address token,
        address from,
        address to,
        uint256 railId,
        uint256 fromEpoch,
        uint256 toEpoch,
        uint256 amount
    ) external view override returns (ArbitrationResult memory) {
        uint256 proofSetId = railToProofSet[railId];
        
        if (proofSetId == 0) {
            return ArbitrationResult({
                modifiedAmount: amount,
                settleUpto: toEpoch,
                note: "No proof set registered"
            });
        }
        
        uint256 faultCount = pdpService.getFaultCount(proofSetId, fromEpoch, toEpoch);
        uint256 reductionPercent = faultCount * 10;
        if (reductionPercent > 100) reductionPercent = 100;
        
        uint256 reduction = amount * reductionPercent / 100;
        uint256 modifiedAmount = amount - reduction;
        
        return ArbitrationResult({
            modifiedAmount: modifiedAmount,
            settleUpto: toEpoch,
            note: string(abi.encodePacked("Reduced by ", faultCount, " faults"))
        });
    }
}
```

### 5. Rail Management

Rails can be modified and terminated:

```javascript
// Modify the payment rate
async function modifyRailPayment(railId, newRate) {
    const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);
    await payments.modifyRailPayment(
        railId,
        newRate,  // New payment rate
        0         // No one-time payment
    );
}

// Terminate the rail
async function terminateRail(railId) {
    const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);
    await payments.terminateRail(railId);
}
```

## Integration with PDP

Payment Rails integrate with the Provable Data Possession (PDP) system through arbiters:

1. A client creates a payment rail with a PDP arbiter
2. The client creates a proof set in the PDP system
3. The arbiter links the rail to the proof set
4. When settling payments, the arbiter checks for faults in the PDP system
5. The arbiter adjusts payment amounts based on proof compliance

```javascript
// Complete integration example
async function setupPDPPaymentIntegration() {
    // Create a payment rail with a PDP arbiter
    const railId = await createPaymentRail();
    
    // Create a proof set with payment information
    const extraData = ethers.utils.defaultAbiCoder.encode(
        ['uint256', 'address'],
        [railId, paymentsContractAddress]
    );
    
    const proofSetId = await createProofSet(pdpServiceAddress, extraData);
    
    // Register the rail-to-proof-set mapping in the arbiter
    await pdpArbiter.registerRailProofSet(railId, proofSetId);
    
    return { railId, proofSetId };
}
```

## Best Practices

### Security Considerations

1. **Fund Management**: Ensure sufficient funds are deposited before creating rails
2. **Rate Limiting**: Set reasonable payment rates to prevent rapid fund depletion
3. **Arbiter Security**: Implement proper access controls in arbiter contracts
4. **Regular Settlement**: Settle payments regularly to maintain accurate balances

### Implementation Tips

1. **Monitoring**: Implement monitoring for rail status and fund levels
2. **Error Handling**: Add robust error handling for contract interactions
3. **Gas Optimization**: Batch operations when managing multiple rails
4. **Testing**: Thoroughly test on testnets before deploying to mainnet

## API Reference

### Core Functions

#### Creating a Rail

```solidity
function createRail(
    address token,
    address from,
    address to,
    address arbiter,
    uint256 paymentRate,
    uint256 lockupPeriod,
    uint256 lockupFixed,
    uint256 commissionRateBps
) external returns (uint256 railId)
```

#### Settling Payments

```solidity
function settleRail(uint256 railId, uint256 settleUpto) external
```

#### Modifying a Rail

```solidity
function modifyRailPayment(
    uint256 railId,
    uint256 newRate,
    uint256 oneTimePayment
) external
```

#### Terminating a Rail

```solidity
function terminateRail(uint256 railId) external
```

## Examples

### Basic Payment Rail

```javascript
// Create a basic payment rail without an arbiter
async function createBasicPaymentRail() {
    const tokenAddress = '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0';
    const clientAddress = wallet.address;
    const providerAddress = '0x123...';
    const arbiterAddress = ethers.constants.AddressZero; // No arbiter
    const paymentRate = ethers.utils.parseUnits('0.01', 6);
    const lockupPeriod = 2880;
    const lockupFixed = ethers.utils.parseUnits('5', 6);
    const commissionRate = 0; // No commission
    
    // Deposit funds
    await depositFunds(tokenAddress, ethers.utils.parseUnits('100', 6));
    
    // Create the rail
    const railId = await createRail(
        tokenAddress,
        clientAddress,
        providerAddress,
        arbiterAddress,
        paymentRate,
        lockupPeriod,
        lockupFixed,
        commissionRate
    );
    
    return railId;
}
```

### PDP-Integrated Payment Rail

```javascript
// Create a payment rail integrated with PDP
async function createPDPPaymentRail() {
    // Create a PDP arbiter
    const pdpArbiterFactory = new ethers.ContractFactory(
        pdpArbiterAbi,
        pdpArbiterBytecode,
        wallet
    );
    
    const pdpArbiter = await pdpArbiterFactory.deploy(pdpServiceAddress);
    await pdpArbiter.deployed();
    
    // Create a payment rail with the PDP arbiter
    const railId = await createRail(
        tokenAddress,
        clientAddress,
        providerAddress,
        pdpArbiter.address,
        paymentRate,
        lockupPeriod,
        lockupFixed,
        commissionRate
    );
    
    return { railId, pdpArbiter };
}
```

## Next Steps

- Learn about [PDP Integration](../../integration/pdp-payments.md)
- Explore the [Payments System](../overview.md)
- Follow the [Quick Start Guide](../../quick-start.md)
- See a complete example in the [Hot Vault Demo](../../examples/hot-vault.md)
