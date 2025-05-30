# MVP - Proof of Concept Configuration

## Overview

The current implementation is a **Minimum Viable Product (MVP)** designed as a proof of concept. This document outlines the manual configuration requirements and limitations of the current system, particularly regarding storage provider selection.

## Current Limitations

### Manual Storage Provider Configuration

**⚠️ Important:** The current MVP does NOT support dynamic storage provider selection. Storage providers must be manually configured using hardcoded values in environment variables.

### No Storage Provider Marketplace

The system currently lacks:
- Dynamic storage provider discovery
- Automatic provider selection based on criteria (price, reputation, availability)
- Provider registration and marketplace functionality
- Bidding or auction mechanisms for storage deals

## Required Manual Configuration

To use the current FW PDP-Payments system, you must manually configure the following values based on your chosen storage provider:

### Server Configuration (Hot Vault Demo)

The following environment variables must be set in your `.env` file:

```env
# PDP Tool & Service Configuration
PDPTOOL_PATH=/absolute/path/to/pdptool
SERVICE_NAME=your-service-name
SERVICE_URL=https://your-service-url.com
RECORD_KEEPER=0xYourRecordKeeperAddress
```

### Calibnet Test Configuration

For testing on Calibration Testnet, use these specific values:

```env
# Calibnet-specific PDP Service Provider values
SERVICE_NAME=pdp-service-name
SERVICE_URL=https://yablu.net
RECORD_KEEPER=0xdbE4bEF3F313dAC36257b0621e4a3BC8Dc9679a1
```

### Client Configuration

The client application also requires hardcoded contract addresses:

```typescript
// Client constants (from constants.ts)
export const USDFC_TOKEN_ADDRESS = "0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0";
export const PAYMENT_PROXY_ADDRESS = "0x0E690D3e60B0576D01352AB03b258115eb84A047";
export const PDP_SERVICE_ADDRESS = "0xdbE4bEF3F313dAC36257b0621e4a3BC8Dc9679a1";
```

## Configuration Requirements

### 1. Service Registration

Before using a storage provider, ensure:
- The service is registered in the PDP Tool with the provider
- The `SERVICE_NAME` matches the registered service name
- The `SERVICE_URL` points to the correct service endpoint

### 2. Record Keeper Address

The `RECORD_KEEPER` address must be:
- A valid Ethereum address
- The address of the PDP service provider on the target network
- Properly funded and authorized to submit proofs

### 3. Network Compatibility

Ensure all addresses and configurations match your target network:
- **Calibration Testnet**: Use the provided Calibnet values
- **Mainnet**: Obtain mainnet-specific addresses from your storage provider
- **Local Development**: Configure local test addresses

## Implications for Users

### For Developers

- You cannot dynamically select storage providers
- All provider information must be known at deployment time
- Switching providers requires code changes and redeployment
- No built-in provider comparison or selection logic

### For Storage Providers

- Must provide configuration values to clients manually
- No automatic registration or discovery mechanism
- Clients must hardcode your service details
- No marketplace presence or competitive bidding

### For End Users

- Limited to the storage provider chosen by the application developer
- No ability to select preferred providers based on price or performance
- No transparency into provider selection criteria

## Future Development

The following features are planned for future releases but not available in the current MVP:

### Dynamic Provider Selection
- Storage provider registry and discovery
- Automatic matching based on requirements
- Real-time provider availability checking

### Marketplace Features
- Provider reputation systems
- Competitive pricing mechanisms
- Service level agreement templates
- Automated provider onboarding

### Enhanced Client Experience
- Provider selection UI components
- Performance and cost comparison tools
- Multi-provider redundancy options

## Migration Path

When dynamic provider selection becomes available:

1. **Configuration Migration**: Environment-based configuration will be supplemented with runtime provider selection
2. **API Changes**: New APIs will be introduced for provider discovery and selection
3. **Backward Compatibility**: Existing hardcoded configurations will continue to work
4. **Gradual Adoption**: Applications can migrate to dynamic selection incrementally

## Getting Started with MVP

To use the current MVP:

1. **Choose a Storage Provider**: Contact a FilOz-compatible storage provider (note: how do we enable developers to do this?)
2. **Obtain Configuration Values**: Get the required SERVICE_NAME, SERVICE_URL, and RECORD_KEEPER values
3. **Configure Your Application**: Set the environment variables as shown above
4. **Deploy and Test**: Deploy your application with the hardcoded provider configuration

## Support

For assistance with MVP configuration:
- Review the [Hot Vault Demo](examples/hot-vault.md) for a complete example
- Check the [Quick Start Guide](quick-start.md) for setup instructions
- Consult the [Troubleshooting Guide](reference/troubleshooting.md) for common issues

---

**Note:** This MVP approach is intentional to validate the core PDP and Payments functionality before building the more complex marketplace and provider selection features. The manual configuration ensures reliable testing and development of the foundational components.
