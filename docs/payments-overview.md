# Payments System Overview

## Introduction

The Payments system is a flexible payment channel solution designed specifically for Filecoin storage deals. It enables ongoing payments between clients and storage providers with built-in arbitration capabilities to enforce Service Level Agreements (SLAs).

## Key Features

- **Payment Channels**: Create dedicated payment channels (rails) between payers and payees
- **Continuous Payments**: Enable ongoing payments at configurable rates
- **SLA Enforcement**: Integrate with arbiters to adjust payments based on service performance
- **Flexible Settlement**: Settle payments on-demand or at scheduled intervals
- **Token Agnostic**: Support any ERC20 token for payments
- **Commission Support**: Enable commission payments to operators

## Core Components

### Payment Rails

A payment rail is a payment channel between a payer (client) and a payee (storage provider) that allows for:

- Continuous payments at a specified rate
- Adjustable payment rates over time
- Optional arbitration for SLA enforcement
- Secure fund lockup and settlement

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

### Accounts

The system tracks funds and lockups for each user:

```solidity
struct Account {
    uint256 funds;              // Available funds
    uint256 lockupCurrent;      // Currently locked funds
    uint256 lockupRate;         // Rate at which funds are locked
    uint256 lockupLastSettledAt; // Last epoch when lockup was settled
}
```

### Arbitration

Arbiters can adjust payment amounts based on service performance:

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

## Core Functionality

### Creating a Rail

Payment rails are created using the `createRail` function:

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

**Parameters:**
- `token`: Address of the ERC20 token to be used for payments
- `from`: Address of the payer (client)
- `to`: Address of the payee (storage provider)
- `arbiter`: Address of the arbiter contract for SLA enforcement (can be zero address)
- `paymentRate`: Rate at which payments flow (tokens per epoch)
- `lockupPeriod`: Number of epochs for which funds are locked
- `lockupFixed`: Fixed amount of funds locked
- `commissionRateBps`: Commission rate in basis points (e.g., 250 for 2.5%)

**Returns:**
- `railId`: The ID of the newly created payment rail

**Example:**
```javascript
// Create a payment rail with USDC
async function createPaymentRail() {
    const tokenAddress = '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'; // USDC on testnet
    const clientAddress = wallet.address;
    const providerAddress = '0x...'; // Storage provider address
    const arbiterAddress = '0x...'; // Arbiter address
    const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDC per epoch
    const lockupPeriod = 2880; // 1 day in epochs
    const lockupFixed = ethers.utils.parseUnits('5', 6); // 5 USDC fixed lockup
    const commissionRate = 250; // 2.5% commission
    
    // First, approve the Payments contract to spend your tokens
    const token = new ethers.Contract(tokenAddress, tokenAbi, wallet);
    await token.approve(paymentsAddress, ethers.utils.parseUnits('100', 6));
    
    // Deposit funds into the Payments contract
    await payments.deposit(tokenAddress, clientAddress, ethers.utils.parseUnits('10', 6));
    
    // Create the payment rail
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

### Settlement Process

Payments are settled using the `settleRail` function:

```solidity
function settleRail(uint256 railId, uint256 settleUpto) external
```

**Parameters:**
- `railId`: The ID of the rail to settle
- `settleUpto`: The epoch up to which to settle payments

**Example:**
```javascript
// Settle payments up to the current epoch
async function settlePayments(railId) {
    const currentEpoch = await provider.getBlockNumber();
    await payments.settleRail(railId, currentEpoch);
}
```

If an arbiter is specified, it will be called to potentially adjust the payment amount based on service performance.

### Managing Rails

Rails can be modified and terminated:

```javascript
// Modify the payment rate
async function modifyRailPayment(railId, newRate) {
    await payments.modifyRailPayment(
        railId,
        newRate,  // New payment rate
        0         // No one-time payment
    );
}

// Terminate the rail
async function terminateRail(railId) {
    await payments.terminateRail(railId);
}
```

## Integration with PDP

The Payments system integrates with the [PDP (Provable Data Possession)](pdp-overview.md) system through the arbiter mechanism:

1. A client creates a payment rail with an arbiter that monitors PDP compliance
2. The PDP system records proof submissions and faults
3. When settling payments, the arbiter checks PDP compliance records
4. The arbiter adjusts payment amounts based on the storage provider's performance

For a detailed guide on integrating Payments with PDP, see [Integrating PDP with Payments](integration-guide.md).

## Deployed Contracts

The Payments contract is deployed on Filecoin Mainnet and Calibration Testnet.

**Mainnet**
- **Payments Contract**: `0x8BA1f109551bD432803012645Ac136ddd64DBA72`

**Calibration Testnet**
- **Payments Contract**: `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A`

## Security Considerations

1. **Fund Safety**: Funds are locked in the contract and can only be withdrawn by the rightful owner
2. **Rate Limiting**: Changes to payment rates have time delays to prevent sudden draining of funds
3. **Arbitration Constraints**: Arbiters can only reduce payments, not increase them
4. **Termination Safeguards**: Terminated rails still honor the lockup period

## Next Steps

- Learn about the [PDP System](pdp-overview.md)
- Understand how to [Integrate PDP with Payments](integration-guide.md)
- Follow the [Quick Start Guide](quick-start.md)
- Explore the [Hot Vault Example](examples/hot-vault.md)
