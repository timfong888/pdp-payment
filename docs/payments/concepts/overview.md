# Payments System Overview

## Introduction

The FilOz Payments system is a flexible payment channel solution designed specifically for Filecoin storage deals. It enables ongoing payments between clients and storage providers with built-in arbitration capabilities to enforce Service Level Agreements (SLAs).

## Key Components

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

**Example:**
```solidity
// Create a payment rail with USDC
uint256 railId = payments.createRail(
    usdcAddress,        // Token address
    clientAddress,      // Payer
    providerAddress,    // Payee
    arbiterAddress,     // Arbiter for SLA enforcement
    1000000,            // Payment rate (1 USDC per epoch)
    2880,               // Lockup period (1 day in epochs)
    5000000,            // Fixed lockup amount (5 USDC)
    250                 // Commission rate (2.5%)
);
```

### Modifying a Rail

Rails can be modified by the operator:

```solidity
// Change the lockup parameters
payments.modifyRailLockup(
    railId,
    3600,     // New lockup period (1.25 days in epochs)
    6000000   // New fixed lockup (6 USDC)
);

// Change the payment rate
payments.modifyRailPayment(
    railId,
    1200000,  // New payment rate (1.2 USDC per epoch)
    0         // No one-time payment
);
```

### Settling Payments

Payments are settled using the `settleRail` function:

```solidity
// Settle payments up to the current epoch
payments.settleRail(
    railId,
    block.number  // Current epoch
);
```

If an arbiter is specified, it will be called to potentially adjust the payment amount based on service performance.

### Terminating a Rail

Rails can be terminated, preventing further payments after the lockup period:

```solidity
// Terminate the rail
payments.terminateRail(
    railId
);
```

## Integration with PDP

The Payments system integrates with the PDP (Provable Data Possession) system through the arbiter mechanism:

1. A client creates a payment rail with an arbiter that monitors PDP compliance
2. The PDP system records proof submissions and faults
3. When settling payments, the arbiter checks PDP compliance records
4. The arbiter adjusts payment amounts based on the storage provider's performance

```solidity
// Example of an arbiter that reduces payments based on PDP faults
function arbitratePayment(
    address token,
    address from,
    address to,
    uint256 railId,
    uint256 fromEpoch,
    uint256 toEpoch,
    uint256 amount
) external view returns (ArbitrationResult memory) {
    // Get fault count from PDP system
    uint256 faultCount = pdpService.getFaultCount(proofSetId);
    
    // Calculate reduction based on faults
    uint256 reduction = amount * faultCount * 10 / 100; // 10% per fault
    
    // Return adjusted amount
    return ArbitrationResult({
        modifiedAmount: amount - reduction,
        settleUpto: toEpoch,
        note: string(abi.encodePacked("Reduced by ", faultCount, " faults"))
    });
}
```

## Security Considerations

1. **Fund Safety**: Funds are locked in the contract and can only be withdrawn by the rightful owner
2. **Rate Limiting**: Changes to payment rates have time delays to prevent sudden draining of funds
3. **Arbitration Constraints**: Arbiters can only reduce payments, not increase them
4. **Termination Safeguards**: Terminated rails still honor the lockup period

## Advanced Features

### Scheduled Rate Changes

Payment rates can be scheduled to change at future epochs:

```solidity
// Schedule a rate change
payments.scheduleRateChange(
    railId,
    block.number + 8640, // 3 days from now
    1500000              // New rate (1.5 USDC per epoch)
);
```

### Commission Payments

The system supports commission payments to operators:

```solidity
// Create a rail with commission
uint256 railId = payments.createRail(
    usdcAddress,
    clientAddress,
    providerAddress,
    arbiterAddress,
    1000000,
    2880,
    5000000,
    500         // 5% commission
);
```

## Next Steps

- [Setting Up Your First Payment Rail](../guides/first-rail.md)
- [Implementing a Custom Arbiter](../guides/custom-arbiter.md)
- [Payments API Reference](../api/payments-contract.md)
