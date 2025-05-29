# PDP-Payments (FWS) Documentation

This repository contains comprehensive documentation for the PDP-Payments (FWS) system, including guides, tutorials, and technical specifications.

## Table of Contents

- [Overview](#overview)
- [Key Components](#key-components)
- [Documentation](#documentation)
- [Deployed Contracts](#deployed-contracts)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Overview

PDP-Payments (FWS) is a comprehensive system for Provable Data Possession (PDP) with integrated payment mechanisms for Filecoin storage providers and clients. It is designed to enhance the Filecoin storage network by providing:

1. **Verifiable Storage**: Cryptographic proofs that storage providers are maintaining client data
2. **Automatic Payments**: Configurable payment channels with adjustments based on proof compliance
3. **SLA Enforcement**: Service Level Agreements enforced through arbitration mechanisms
4. **Continuous Payment Flow**: Payments that flow as long as storage services are properly provided

This documentation repository serves as a central resource for understanding how the various components of the PDP-Payments (FWS) system work together.

## Key Components

### PDP (Provable Data Possession)

The PDP system allows storage providers to prove they are still storing client data without having to retrieve the entire dataset:

- **PDPVerifier Contract**: Handles verification of proofs submitted by storage providers
- **SimplePDPService**: Implements SLA terms for proof frequency and requirements
- **Proof Sets**: Data structures tracking the data being proven, owner, and proof history

### Payments System

The payments system provides flexible payment channels between clients and storage providers:

- **Payment Rails**: Channels connecting payers and payees with configurable payment rates
- **Arbitration**: Third-party arbiters that modify payment amounts based on service delivery
- **Settlement**: Process ensuring payments are made according to agreed terms

### Integration

The integration between PDP and Payments enables:

- **Verifiable Storage with Automatic Payment Adjustments**: Payments adjusted based on proof compliance
- **SLA Enforcement**: Service Level Agreements enforced through arbitration
- **Continuous Payment Flow**: Payments flow as long as service is properly provided

## Documentation

- [PDP Overview](docs/pdp-overview.md): Detailed explanation of the PDP system
- [Payments Overview](docs/payments/concepts/overview.md): Detailed explanation of the Payments system
- [Payment Rails](docs/payments/payment-rails.md): Documentation on payment rails
- [Integration Guide](docs/integration/pdp-payments.md): Guide for integrating PDP with Payments
- [System Diagrams](docs/diagrams.md): Visual representations of system architecture and workflows
- [Quick Start](docs/quick-start.md): Quick start guide for developers
- [Hot Vault Example](docs/examples/hot-vault.md): Example implementation

## Deployed Contracts

### Mainnet

- **PDP Verifier**: `0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6`
- **PDP Service**: `0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019`
- **Payments Contract**: `0x8BA1f109551bD432803012645Ac136ddd64DBA72`

### Calibration Testnet

- **PDP Verifier**: `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC`
- **PDP Service**: `0x6170dE2b09b404776197485F3dc6c968Ef948505`
- **Payments Contract**: `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A`

## Getting Started

### 🚀 Golden Path: Your First Success

**Are you building an app or developing contracts?**

#### 📱 **App Developer Path** (Recommended for most users)
Build apps using existing PDP-Payments contracts - no contract development needed:

1. **[Setup Wallet & USDFC](docs/setup.md)** - Configure MetaMask with Calibration testnet and get USDFC tokens
2. **[Configure JSON-RPC](docs/setup-detailed.md)** - Set up Filecoin JSON-RPC for blockchain interactions
3. **[Install Synapse SDK](docs/quick-start.md)** - Create a local app using the Synapse SDK
4. **[Store Your First File](docs/first-deal.md)** - Upload a photo from your desktop to a storage provider
5. **[Verify Storage Proof](docs/pdp-overview.md)** - Confirm your file is being stored with cryptographic proofs
6. **[Retrieve Your File](docs/examples/hot-vault.md)** - Download your stored file back to your device

#### ⚙️ **Contract Developer Path** (Advanced users)
Deploy custom contracts or modify existing ones:
- Follow the App Developer Path above, then
- [Contract Development Guide](docs/contracts/development.md) - Hardhat/Foundry setup for custom contracts

### 📚 Deep Dive Documentation

Once you've completed the Golden Path:

1. Understand the [PDP System](docs/pdp-overview.md) and [Payments System](docs/payments-overview.md)
2. Learn how to [Integrate PDP with Payments](docs/integration-guide.md)
3. Explore advanced [Integration Patterns](docs/integration/pdp-payments.md)

## Contributing

We welcome contributions to the documentation! Please see our [contribution guidelines](docs/contributing.md) for more information.

## License

This documentation is licensed under [MIT License](LICENSE).
