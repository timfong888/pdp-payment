# Contract Address Details

This document provides human-readable definitions and explanations for the key contract addresses used in the PDP-Payments system.

## Overview

The PDP-Payments system uses several smart contracts deployed on the Filecoin network. These addresses are **system-defined** and **not user-configurable**. They represent core infrastructure components that all users interact with.

## Key Contract Addresses

### USDFC Token Address

**What it is:** The address of the USDFC (USD Filecoin) stablecoin contract - a USD-pegged token used for payments in the system.

**Purpose:** 
- Serves as the primary payment token for storage services
- Provides price stability for storage payments (pegged to USD)
- Enables programmable payments through smart contracts

**Who sets it up:** 
- Deployed and maintained by the USDFC token issuer
- **Not user-defined** - this is a system-wide token contract

**Current addresses:**
- **Calibration Testnet:** `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0`
- **Mainnet:** (Contact system administrators for mainnet address)

**How it's used:**
- Clients deposit USDFC tokens to fund storage payments
- Storage providers receive USDFC tokens as payment for services
- All payment calculations and settlements are denominated in USDFC

### Payment Proxy Address (Payments Contract)

**What it is:** The main Payments contract that manages payment rails, fund deposits, and settlement between clients and storage providers.

**Purpose:**
- Manages user account balances and fund deposits
- Creates and manages payment rails between clients and providers
- Handles payment settlement and arbitration
- Enforces payment lockup periods and commission rates

**Who sets it up:**
- Deployed by the PDP-Payments system administrators
- **Not user-defined** - this is core system infrastructure

**Current addresses:**
- **Calibration Testnet:** `0x0E690D3e60B0576D01352AB03b258115eb84A047`
- **Mainnet:** `0x8BA1f109551bD432803012645Ac136ddd64DBA72`

**How it's used:**
- Clients deposit USDFC tokens into this contract
- Clients create payment rails through this contract
- Storage providers receive payments from this contract
- Arbiters interact with this contract to adjust payments based on service quality

### PDP Service Address

**What it is:** The SimplePDPService contract address that implements the Service Level Agreement (SLA) terms for the PDP (Provable Data Possession) system.

**Purpose:**
- Defines proof frequency requirements (how often storage providers must submit proofs)
- Specifies challenge windows (time periods for proof submission)
- Records faults when storage providers fail to submit valid proofs
- Integrates with the payment system to adjust payments based on proof compliance

**Who sets it up:**
- Deployed by the PDP system administrators
- **Not user-defined** - this is core system infrastructure

**Current addresses:**
- **Calibration Testnet:** `0xdbE4bEF3F313dAC36257b0621e4a3BC8Dc9679a1`
- **Mainnet:** `0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019`

**How it's used:**
- Referenced when creating proof sets in the PDP Verifier contract
- Monitors storage provider proof submissions
- Records faults for missed or invalid proofs
- Provides fault data to arbiters for payment adjustments

## Additional System Contracts

### PDP Verifier Address

**What it is:** The PDPVerifier contract that manages proof sets and verifies storage proofs.

**Current addresses:**
- **Calibration Testnet:** `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC`
- **Mainnet:** `0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6`

## Important Notes

### User vs System Configuration

**System-Defined (Not User Configurable):**
- All contract addresses listed above
- Token contract specifications
- Network-specific deployments
- Core protocol parameters

**User-Defined:**
- Storage provider addresses (who you pay)
- Payment rates (how much you pay)
- Lockup periods (how long funds are locked)
- Arbiter selection (which arbiter monitors service quality)

### Network Compatibility

All addresses are network-specific:
- **Calibration Testnet:** Use for development and testing
- **Mainnet:** Use for production deployments
- **Never mix addresses** between networks

### Security Considerations

- These addresses are part of the core protocol infrastructure
- Always verify addresses against official documentation
- Use environment variables to manage network-specific addresses
- Never hardcode addresses directly in production code

## Integration Examples

### Environment Configuration

```bash
# Calibration Testnet
USDFC_TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0
PAYMENT_PROXY_ADDRESS=0x0E690D3e60B0576D01352AB03b258115eb84A047
PDP_SERVICE_ADDRESS=0xdbE4bEF3F313dAC36257b0621e4a3BC8Dc9679a1
PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
```

### Code Usage

```javascript
// These addresses are system infrastructure - not user-defined
const SYSTEM_CONTRACTS = {
  USDFC_TOKEN: process.env.USDFC_TOKEN_ADDRESS,
  PAYMENTS: process.env.PAYMENT_PROXY_ADDRESS,
  PDP_SERVICE: process.env.PDP_SERVICE_ADDRESS,
  PDP_VERIFIER: process.env.PDP_VERIFIER_ADDRESS
};

// User-defined parameters
const USER_CONFIG = {
  storageProvider: '0x...', // Your chosen storage provider
  paymentRate: '0.01',      // Your payment rate
  lockupPeriod: 2880        // Your lockup period
};
```

## Related Documentation

- [MVP Configuration Guide](MVP.md) - Complete setup instructions
- [Payments Overview](payments-overview.md) - How the payment system works
- [PDP Overview](pdp-overview.md) - How the proof system works
- [Integration Guide](integration/pdp-payments.md) - Connecting PDP with Payments
