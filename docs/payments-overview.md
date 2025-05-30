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

**Example: Creating a Storage Payment Rail**

Let's create a payment rail for a typical storage deal scenario:

**Scenario**: A client wants to store 1GB of data for 6 months with a storage provider.

**Real-World Costs & Timing:**
- **Storage Duration**: 6 months (approximately 180 days)
- **Total Cost**: $18 USD for 6 months of storage
- **Monthly Cost**: $3 USD per month
- **Daily Cost**: $0.10 USD per day
- **Hourly Cost**: ~$0.004 USD per hour

**How This Translates to Payment Rail Attributes:**

```javascript
// Create a payment rail with USDFC (Filecoin's USD stablecoin)
async function createPaymentRail() {
    const tokenAddress = '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'; // USDFC on testnet
    const clientAddress = wallet.address;
    const providerAddress = '0x...'; // Storage provider address
    const arbiterAddress = '0x...'; // PDP arbiter for proof verification

    // Payment Rate Calculation:
    // - Filecoin epoch = 30 seconds
    // - Daily cost: $0.10 USD = 0.10 USDFC
    // - Epochs per day: 24 hours × 60 minutes × 2 epochs/minute = 2,880 epochs
    // - Payment rate: 0.10 USDFC ÷ 2,880 epochs = ~0.0000347 USDFC per epoch
    const paymentRate = ethers.utils.parseUnits('0.0000347', 6); // ~$0.10 per day

    // Lockup Period:
    // - 1 day buffer for proof verification = 2,880 epochs
    const lockupPeriod = 2880; // 1 day in epochs (safety buffer)

    // Fixed Lockup:
    // - Security deposit equivalent to 1 week of payments = $0.70
    const lockupFixed = ethers.utils.parseUnits('0.70', 6); // 1 week security deposit

    const commissionRate = 250; // 2.5% commission to platform operator
    
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

## What is Settlement and How It Occurs

**Settlement** is the process of calculating and transferring the actual payments from the client to the storage provider based on the agreed payment rate and any adjustments made by arbiters.

### How Settlement Works

1. **Continuous Accrual**: Payments accrue continuously at the specified rate (e.g., $0.10 per day)
2. **Periodic Settlement**: Actual token transfers happen when `settleRail()` is called
3. **Arbiter Adjustments**: If a PDP arbiter is configured, it can reduce payments based on proof compliance
4. **Final Transfer**: Tokens are transferred from the client's locked funds to the storage provider

### Settlement Timing

Settlement can occur:
- **On-Demand**: Anyone can call `settleRail()` to trigger settlement up to the current epoch
- **Automatically**: Through scheduled calls or when specific events occur (e.g., proof submission)
- **At Termination**: When a rail is terminated, all outstanding payments are settled

### Settlement Example

```javascript
// Example: Settlement with PDP compliance checking
async function settleWithCompliance(railId) {
    const currentEpoch = await provider.getBlockNumber();

    // When settlement is called, the system:
    // 1. Calculates total payment owed (rate × time elapsed)
    // 2. Calls the PDP arbiter to check proof compliance
    // 3. Arbiter may reduce payment if proofs were missed
    // 4. Transfers the final amount to storage provider

    await payments.settleRail(railId, currentEpoch);

    console.log('Settlement completed with PDP compliance verification');
}
```

### Settlement Scenarios

**Scenario 1: Perfect Compliance**
- Client owes $3.00 for 30 days of storage
- Storage provider submitted all required proofs
- **Result**: Full $3.00 is transferred to storage provider

**Scenario 2: Missed Proofs**
- Client owes $3.00 for 30 days of storage
- Storage provider missed proofs for 3 days (10% downtime)
- PDP arbiter reduces payment by 10%
- **Result**: $2.70 is transferred to storage provider, $0.30 remains with client

**Scenario 3: Early Termination**
- Client terminates storage after 15 days
- Only $1.50 in payments have accrued
- **Result**: $1.50 is transferred to storage provider, remaining funds returned to client

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

## Advanced Features

### Scheduled Rate Changes

Payment rates can be scheduled to change at future epochs, allowing for dynamic pricing models:

```javascript
// Schedule a rate change for 3 days from now
async function scheduleRateChange(railId, newRate) {
    const futureEpoch = await provider.getBlockNumber() + 8640; // 3 days = 8640 epochs

    await payments.scheduleRateChange(
        railId,
        futureEpoch,
        ethers.utils.parseUnits(newRate, 6) // New rate in USDFC
    );

    console.log(`Rate change scheduled for epoch ${futureEpoch}`);
}
```

### Commission Payments

The system supports commission payments to platform operators:

```javascript
// Create a rail with 5% commission to platform
async function createRailWithCommission() {
    const railId = await payments.createRail(
        tokenAddress,
        clientAddress,
        providerAddress,
        arbiterAddress,
        paymentRate,
        lockupPeriod,
        lockupFixed,
        500 // 5% commission (500 basis points)
    );

    return railId;
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
