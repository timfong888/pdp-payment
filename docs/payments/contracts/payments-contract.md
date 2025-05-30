# Payments Contract API Reference

This document provides a comprehensive reference for the FilOz Payments contract API.

## Core Structures

### Rail

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

### Account

```solidity
struct Account {
    uint256 funds;              // Available funds
    uint256 lockupCurrent;      // Currently locked funds
    uint256 lockupRate;         // Rate at which funds are locked
    uint256 lockupLastSettledAt; // Last epoch when lockup was settled
}
```

### RateChange

```solidity
struct RateChange {
    uint256 epoch;       // Epoch at which the rate change takes effect
    uint256 paymentRate; // New payment rate
}
```

### ArbitrationResult

```solidity
struct ArbitrationResult {
    uint256 modifiedAmount; // Adjusted payment amount
    uint256 settleUpto;     // Epoch up to which to settle
    string note;            // Additional information
}
```

## State Variables

| Name | Type | Description |
|------|------|-------------|
| `accounts` | `mapping(address => mapping(address => Account))` | Maps token and user to their account |
| `rails` | `mapping(uint256 => Rail)` | Maps rail ID to rail data |
| `nextRailId` | `uint256` | Counter for generating unique rail IDs |

## Events

### RailCreated

```solidity
event RailCreated(
    uint256 indexed railId,
    address indexed from,
    address indexed to,
    address token,
    uint256 paymentRate,
    uint256 lockupPeriod,
    uint256 lockupFixed,
    uint256 commissionRateBps
);
```

Emitted when a new payment rail is created.

### RailLockupModified

```solidity
event RailLockupModified(
    uint256 indexed railId,
    uint256 lockupPeriod,
    uint256 lockupFixed
);
```

Emitted when a rail's lockup parameters are modified.

### RailPaymentModified

```solidity
event RailPaymentModified(
    uint256 indexed railId,
    uint256 paymentRate,
    uint256 oneTimePayment
);
```

Emitted when a rail's payment parameters are modified.

### RailTerminated

```solidity
event RailTerminated(
    uint256 indexed railId,
    uint256 endEpoch
);
```

Emitted when a rail is terminated.

### RailSettled

```solidity
event RailSettled(
    uint256 indexed railId,
    uint256 fromEpoch,
    uint256 toEpoch,
    uint256 amount,
    uint256 commission
);
```

Emitted when a rail is settled.

### Deposited

```solidity
event Deposited(
    address indexed token,
    address indexed user,
    uint256 amount
);
```

Emitted when a user deposits funds.

### Withdrawn

```solidity
event Withdrawn(
    address indexed token,
    address indexed user,
    uint256 amount
);
```

Emitted when a user withdraws funds.

### RateChangeScheduled

```solidity
event RateChangeScheduled(
    uint256 indexed railId,
    uint256 epoch,
    uint256 paymentRate
);
```

Emitted when a rate change is scheduled.

## Functions

### deposit

```solidity
function deposit(
    address token,
    address user,
    uint256 amount
) external
```

Deposits tokens into a user's account.

**Parameters:**
- `token`: Address of the ERC20 token to deposit
- `user`: Address of the user to deposit for
- `amount`: Amount of tokens to deposit

**Requirements:**
- The caller must have approved the contract to spend their tokens

### withdraw

```solidity
function withdraw(
    address token,
    uint256 amount
) external
```

Withdraws tokens from the caller's account.

**Parameters:**
- `token`: Address of the ERC20 token to withdraw
- `amount`: Amount of tokens to withdraw

**Requirements:**
- The caller must have sufficient available (non-locked) funds

### createRail

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

Creates a new payment rail.

**Parameters:**
- `token`: Address of the ERC20 token to use for payments
- `from`: Address of the payer
- `to`: Address of the payee
- `arbiter`: Address of the arbiter (can be zero address for no arbitration)
- `paymentRate`: Rate at which payments flow (per epoch)
- `lockupPeriod`: Number of epochs for which funds are locked
- `lockupFixed`: Fixed amount of funds locked
- `commissionRateBps`: Commission rate in basis points (1/100 of a percent)

**Returns:**
- `railId`: ID of the created rail

**Requirements:**
- The caller becomes the operator of the rail

### modifyRailLockup

```solidity
function modifyRailLockup(
    uint256 railId,
    uint256 lockupPeriod,
    uint256 lockupFixed
) external
```

Modifies a rail's lockup parameters.

**Parameters:**
- `railId`: ID of the rail to modify
- `lockupPeriod`: New lockup period
- `lockupFixed`: New fixed lockup amount

**Requirements:**
- The caller must be the rail's operator
- The rail must not be terminated

### modifyRailPayment

```solidity
function modifyRailPayment(
    uint256 railId,
    uint256 paymentRate,
    uint256 oneTimePayment
) external
```

Modifies a rail's payment parameters.

**Parameters:**
- `railId`: ID of the rail to modify
- `paymentRate`: New payment rate
- `oneTimePayment`: One-time payment amount (can be zero)

**Requirements:**
- The caller must be the rail's operator
- The rail must not be terminated

### terminateRail

```solidity
function terminateRail(
    uint256 railId
) external
```

Terminates a rail, preventing further payments after the lockup period.

**Parameters:**
- `railId`: ID of the rail to terminate

**Requirements:**
- The caller must be the rail's operator or the payer
- The rail must not already be terminated

### settleRail

```solidity
function settleRail(
    uint256 railId,
    uint256 toEpoch
) external
```

Settles payments for a rail up to the specified epoch.

**Parameters:**
- `railId`: ID of the rail to settle
- `toEpoch`: Epoch up to which to settle payments

**Requirements:**
- The rail must not be terminated, or if terminated, the lockup period must not have passed
- `toEpoch` must be greater than the last settled epoch

### settleTerminatedRailWithoutArbitration

```solidity
function settleTerminatedRailWithoutArbitration(
    uint256 railId
) external
```

Settles payments for a terminated rail without arbitration.

**Parameters:**
- `railId`: ID of the rail to settle

**Requirements:**
- The rail must be terminated
- The lockup period must have passed
- The caller must be the payer

### scheduleRateChange

```solidity
function scheduleRateChange(
    uint256 railId,
    uint256 epoch,
    uint256 paymentRate
) external
```

Schedules a rate change for a future epoch.

**Parameters:**
- `railId`: ID of the rail to modify
- `epoch`: Epoch at which the rate change takes effect
- `paymentRate`: New payment rate

**Requirements:**
- The caller must be the rail's operator
- The rail must not be terminated
- The epoch must be in the future

### getRail

```solidity
function getRail(
    uint256 railId
) external view returns (Rail memory)
```

Gets the details of a rail.

**Parameters:**
- `railId`: ID of the rail to get

**Returns:**
- The rail data

### getAccount

```solidity
function getAccount(
    address token,
    address user
) external view returns (Account memory)
```

Gets the account details for a user and token.

**Parameters:**
- `token`: Address of the ERC20 token
- `user`: Address of the user

**Returns:**
- The account data

### calculateSettlementAmount

```solidity
function calculateSettlementAmount(
    uint256 railId,
    uint256 fromEpoch,
    uint256 toEpoch
) external view returns (uint256)
```

Calculates the settlement amount for a rail between two epochs.

**Parameters:**
- `railId`: ID of the rail
- `fromEpoch`: Starting epoch
- `toEpoch`: Ending epoch

**Returns:**
- The settlement amount

## Interfaces

### IArbiter

```solidity
interface IArbiter {
    struct ArbitrationResult {
        uint256 modifiedAmount;
        uint256 settleUpto;
        string note;
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

Interface for arbiter contracts that can adjust payment amounts based on service performance.
