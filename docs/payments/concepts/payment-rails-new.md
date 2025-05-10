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

### Epoch Duration

In the Filecoin network, one epoch is approximately **30 seconds** in clock time. This is a fundamental parameter in the system because:

1. The `paymentRate` is specified as tokens per epoch
2. The `lockupPeriod` is measured in epochs (e.g., 2880 epochs = 1 day)
3. Settlement intervals and proof submission windows are measured in epochs

When calculating costs and rates, this epoch duration must be considered:

```javascript
// Converting between time-based rates and epoch-based rates
// Example: $5/month for 100 GB of data
const dollarsPerMonth = 5.0;
const secondsPerMonth = 30 * 24 * 60 * 60; // 30 days in seconds
const secondsPerEpoch = 30; // 30 seconds per epoch
const epochsPerMonth = secondsPerMonth / secondsPerEpoch; // ~86,400 epochs
const dollarsPerEpoch = dollarsPerMonth / epochsPerMonth; // ~$0.0000579 per epoch

console.log(`Monthly rate: $${dollarsPerMonth}`);
console.log(`Per-epoch rate: $${dollarsPerEpoch.toFixed(8)}`);
console.log(`Token units per epoch (6 decimals): ${ethers.utils.parseUnits(dollarsPerEpoch.toFixed(8), 6)}`);
// Output:
// Monthly rate: $5
// Per-epoch rate: $0.00005787
// Token units per epoch (6 decimals): 57870
```

### Payment Rate Calculation

The `paymentRate` parameter represents the rate at which funds flow from the client to the storage provider per epoch. This rate is typically calculated off-chain based on several factors:

```javascript
// Example of calculating payment rate based on data size and market factors
function calculatePaymentRate(dataSize, storagePrice, epochsPerDay) {
    // Convert data size to GB
    const dataSizeGB = dataSize / (1024 * 1024 * 1024);
    
    // Calculate daily cost based on market price per GB
    const dailyCost = dataSizeGB * storagePrice;
    
    // Convert to per-epoch rate
    const paymentRate = ethers.utils.parseUnits(
        (dailyCost / epochsPerDay).toFixed(6),
        6
    );
    
    return paymentRate;
}

// Usage example for $5/month for 100 GB
const dataSize = 100 * 1024 * 1024 * 1024; // 100 GB in bytes
const daysPerMonth = 30;
const dailyRate = 5 / daysPerMonth; // $0.1667 per day for 100 GB
const pricePerGBPerDay = dailyRate / 100; // $0.001667 per GB per day
const epochsPerDay = 2880; // 30-second epochs
const rate = calculatePaymentRate(dataSize, pricePerGBPerDay, epochsPerDay);

console.log(`Payment rate for 100 GB at $5/month: ${rate} token units per epoch`);
// This would result in approximately 57,870 token units per epoch
```

Factors that typically influence the payment rate include:

1. **Data Size**: Larger data requires more storage resources
2. **Storage Duration**: Longer commitments may have different pricing
3. **Market Rates**: Competitive pricing based on current market conditions
4. **Quality of Service**: Premium service levels (such as faster retrieval times, higher redundancy, or better geographic distribution) may command higher rates and are negotiated between the client and storage provider

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
