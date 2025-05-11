# PDP-Payments (FWS) Documentation

This repository contains comprehensive documentation for the FilOz ecosystem, including guides, tutorials, and technical specifications for all FilOz projects.

## Table of Contents

- [Overview](#overview)
- [Projects](#projects)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Overview

FilOz is a suite of tools and contracts for Filecoin storage providers and clients, focusing on Provable Data Possession (PDP) and payment mechanisms for storage deals.

This documentation repository serves as a central resource for understanding how the various components of the FilOz ecosystem work together.

## Projects

The FilOz ecosystem consists of the following key projects:

- **PDP (Provable Data Possession)**: Smart contracts for verifying data possession on Filecoin
- **Payments**: Payment rails and arbitration for storage deals
- **Client Contract**: Contract for creating and managing storage deals
- **Deal Bounty Contract**: Contract for incentivizing storage deals
- **PDP Explorer**: UI for exploring the PDP hot storage network
- **FilForwarder**: Tool for forwarding deals to storage providers
- **DAGParts**: Library for working with content-addressable data

## Getting Started

To get started with FilOz, please refer to the following guides:

- [Introduction to FilOz](docs/introduction.md)
- [Setting Up Your Environment](docs/setup.md)
- [Creating Your First Storage Deal](docs/first-deal.md)
- [Understanding PDP](docs/pdp-overview.md)
- [Payment Mechanisms](docs/payments.md)

## Contributing

We welcome contributions to the documentation! Please see our [contribution guidelines](docs/contributing.md) for more information.
=======
# PDP Payment System

A comprehensive system for Provable Data Possession (PDP) with integrated payment mechanisms for Filecoin storage providers and clients.

## Overview

The PDP Payment system is a suite of smart contracts and tools designed to enhance the Filecoin storage network by providing:

1. **Verifiable Storage**: Cryptographic proofs that storage providers are maintaining client data
2. **Automatic Payments**: Configurable payment channels with adjustments based on proof compliance
3. **SLA Enforcement**: Service Level Agreements enforced through arbitration mechanisms
4. **Continuous Payment Flow**: Payments that flow as long as storage services are properly provided

This repository contains comprehensive documentation for understanding and implementing the PDP Payment system.

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
- [Payments Overview](docs/payments-overview.md): Detailed explanation of the Payments system
- [Integration Guide](docs/integration-guide.md): Guide for integrating PDP with Payments
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

To get started with the PDP Payment system:

1. Review the [Quick Start Guide](docs/quick-start.md)
2. Understand the [PDP System](docs/pdp-overview.md) and [Payments System](docs/payments-overview.md)
3. Learn how to [Integrate PDP with Payments](docs/integration-guide.md)
4. Explore the [Hot Vault Example](docs/examples/hot-vault.md)
>>>>>>> update-payment-rate-docs

## License

This documentation is licensed under [MIT License](LICENSE).
