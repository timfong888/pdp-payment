# Payments System Overview

## Introduction

The FilOz Payments system is a flexible payment channel solution designed specifically for Filecoin storage deals. It enables ongoing payments between clients and storage providers with built-in arbitration capabilities to enforce Service Level Agreements (SLAs).

## Key Features

- **Payment Channels**: Create dedicated payment channels (rails) between payers and payees
- **Continuous Payments**: Enable ongoing payments at configurable rates
- **SLA Enforcement**: Integrate with arbiters to adjust payments based on service performance
- **Flexible Settlement**: Settle payments on-demand or at scheduled intervals
- **Token Agnostic**: Support any ERC20 token for payments
- **Commission Support**: Enable commission payments to operators

## Core Components

### [Payment Rails](payment-rails.md)

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

For more details on payment rails, see [Payment Rails](payment-rails.md).

### [Accounts](../api/account-management.md)

The system tracks funds and lockups for each user:

```solidity
struct Account {
    uint256 funds;              // Available funds
    uint256 lockupCurrent;      // Currently locked funds
    uint256 lockupRate;         // Rate at which funds are locked
    uint256 lockupLastSettledAt; // Last epoch when lockup was settled
}
```

For more details on account management, see [Account Management](../api/account-management.md).

### [Arbitration](arbitration.md)

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

For more details on arbitration, see [Arbitration](arbitration.md).

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

For a step-by-step guide on creating a rail, see [Setting Up a Payment Rail](../guides/first-rail.md).

### [Settlement Process](settlement.md)

Payments are settled using the `settleRail` function:

```solidity
// Settle payments up to the current epoch
payments.settleRail(
    railId,
    block.number  // Current epoch
);
```

If an arbiter is specified, it will be called to potentially adjust the payment amount based on service performance.

For more details on the settlement process, see [Settlement Process](settlement.md).

### [Managing Rails](../guides/managing-rails.md)

Rails can be modified and terminated:

```solidity
// Modify the payment rate
payments.modifyRailPayment(
    railId,
    1200000,  // New payment rate (1.2 USDC per epoch)
    0         // No one-time payment
);

// Terminate the rail
payments.terminateRail(
    railId
);
```

For more details on managing rails, see [Managing Rails](../guides/managing-rails.md).

## Integration with PDP

The Payments system integrates with the [PDP (Provable Data Possession)](../../pdp/concepts/overview.md) system through the arbiter mechanism:

1. A client creates a payment rail with an arbiter that monitors PDP compliance
2. The PDP system records proof submissions and faults
3. When settling payments, the arbiter checks PDP compliance records
4. The arbiter adjusts payment amounts based on the storage provider's performance

For a detailed guide on integrating Payments with PDP, see [Integrating PDP with Payments](../../integration/pdp-payments.md).

## Deployed Contracts

The Payments contract is deployed on Filecoin Mainnet and Calibration Testnet.

> Disclaimer: ⚠️ These contracts are still under beta testing and might be upgraded for bug fixes and/or improvements. Please use with caution for production environments. ⚠️

**Mainnet**
- [Payments Contract](https://filfox.info/en/address/0x8BA1f109551bD432803012645Ac136ddd64DBA72): `0x8BA1f109551bD432803012645Ac136ddd64DBA72`

**Calibration Testnet**
- [Payments Contract](https://calibration.filfox.info/en/address/0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A): `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A`

## Security Considerations

1. **Fund Safety**: Funds are locked in the contract and can only be withdrawn by the rightful owner
2. **Rate Limiting**: Changes to payment rates have time delays to prevent sudden draining of funds
3. **Arbitration Constraints**: Arbiters can only reduce payments, not increase them
4. **Termination Safeguards**: Terminated rails still honor the lockup period

For more details on security considerations, see [Security Considerations](../../reference/security.md).

## Example Use Cases

### Hot Vault Storage

The [Hot Vault Demo](../../examples/hot-vault.md) demonstrates how the Payments system can be used to pay for hot storage with PDP verification:

1. Client creates a payment rail to the storage provider
2. Client creates a proof set in the PDP system, linking it to the payment rail
3. Storage provider submits proofs regularly to demonstrate data possession
4. Payments flow continuously, adjusted based on proof compliance

### Storage Provider Integration

Storage providers can integrate with the Payments system to:

1. Receive continuous payments for storage services
2. Demonstrate compliance with SLAs through PDP
3. Manage multiple payment rails from different clients

For more details, see [Storage Provider Integration](../../examples/storage-provider.md).

## Next Steps

- [Setting Up Your First Payment Rail](../guides/first-rail.md)
- [Implementing a Custom Arbiter](../guides/custom-arbiter.md)
- [Managing Funds](../guides/managing-funds.md)
- [Payments API Reference](../api/payments-contract.md)
- [Integrating PDP with Payments](../../integration/pdp-payments.md)
