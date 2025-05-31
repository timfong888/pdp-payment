# PDP-Payments (FWS) Documentation

This repository contains comprehensive documentation for the PDP-Payments (FWS) system, including guides, tutorials, and technical specifications.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Synapse SDK](#synapse-sdk)
- [Key Components](#key-components)
- [Documentation](#documentation)
- [Deployed Contracts](#deployed-contracts)

## Overview

PDP-Payments (FWS) is a comprehensive system for Provable Data Possession (PDP) with integrated payment mechanisms for Filecoin storage providers and clients. It is designed to enhance the Filecoin storage network by providing:

1. **Verifiable Storage**: Cryptographic proofs that storage providers are maintaining client data
2. **Automatic Payments**: Configurable payment channels with adjustments based on proof compliance
3. **SLA Enforcement**: Service Level Agreements enforced through arbitration mechanisms
4. **Continuous Payment Flow**: Payments that flow as long as storage services are properly provided

This documentation repository serves as a central resource for understanding how the various components of the PDP-Payments (FWS) system work together.

## Getting Started

### 🚀 Choose Your Path to Success

**What do you want to build?**

#### 📱 **Developer Path: Build Apps Fast** (Recommended)
Use the [Synapse SDK](https://github.com/FilOzone/synapse-sdk) for rapid development with integrated PDP + Payments:

**⚡ 5-Minute Hello World**
1. **[Setup Wallet & USDFC](docs/setup.md)** - Get testnet tokens (shared setup)
2. **[Quick SDK Setup](docs/sdk/sdk-quickstart.md)** - Install and initialize Synapse SDK
3. **[Complete Workflow](docs/sdk/sdk-workflow.md)** - Store file + handle payments in ~20 lines
4. **[Monitor & Verify](docs/sdk/sdk-monitoring.md)** - Track storage proofs and payments

**💡 Why SDK?** Abstract away complexity - automatic payment escrow, built-in settlement, simple balance management.

#### 🤖 **AI Agent Path: Maximum Control** (Advanced)
Direct contract interactions for full technical control:

**🔧 Technical Deep Dive**
1. **[Setup Wallet & USDFC](docs/setup.md)** - Get testnet tokens (shared setup)
2. **[Blockchain Configuration](docs/setup-detailed.md)** - JSON-RPC, Viem patterns, environment setup
3. **[Contract Integration](docs/contracts-guide.md)** - Direct PDP and Payment contract calls
4. **[Advanced Patterns](docs/examples/hot-vault.md)** - Production-ready examples
   - **[Traditional Hot Vault](docs/examples/hot-vault.md)** - Reference implementation with Docker
   - **[Modern Wagmi-Vercel Hot Vault](docs/examples/wagmi-vercel-hotvault.md)** - Serverless Web3 app with Wagmi v2

**🎯 Why Contracts?** Full control over every transaction, custom logic, advanced error handling.

### 📚 Deep Dive Documentation

Once you've completed the Golden Path:

1. Understand the [PDP System](docs/pdp-overview.md) and [Payments System](docs/payments-overview.md)
2. Learn how to [Integrate PDP with Payments](docs/integration-guide.md)
3. Explore advanced [Integration Patterns](docs/integration/pdp-payments.md)

## Synapse SDK

The **Synapse SDK** is the primary interface for developers to interact with the PDP-Payments system. It provides a simple JavaScript/TypeScript API that abstracts away the complexity of direct contract interactions.

### Key Features

- **🎯 Simple API**: Store files in ~5 lines of code
- **💰 Integrated Payments**: Automatic USDFC handling and payment escrow
- **🔍 PDP Verification**: Built-in storage proofs and verification
- **📦 TypeScript Support**: Full type safety and IntelliSense
- **⚡ CDN Integration**: Optional CDN-accelerated file retrievals
- **🔄 Real-time Monitoring**: Track storage status and payment settlements

### Quick Example

```javascript
import { Synapse } from 'synapse-sdk'

// Initialize SDK
const synapse = new Synapse({
  privateKey: process.env.PRIVATE_KEY,
  withCDN: true
})

// Store file with automatic payment handling
const storage = await synapse.createStorage()
const uploadTask = storage.upload(fileData)
const commp = await uploadTask.commp()
await uploadTask.done()
```

### Documentation & Resources

- **[SDK Quick Start Guide](docs/sdk/sdk-quickstart.md)** - Get started in 5 minutes
- **[Complete Workflow Tutorial](docs/sdk/sdk-workflow.md)** - End-to-end storage + payments
- **[Production Deployment Guide](docs/sdk/sdk-production.md)** - Scale to production
- **[SDK Repository](https://github.com/FilOzone/synapse-sdk)** - Source code and advanced documentation

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

- [Quick Start](docs/quick-start.md): Quick start guide for developers
- [PDP Overview](docs/pdp-overview.md): Detailed explanation of the PDP system
- [SDK Documentation](docs/sdk/sdk-quickstart.md): Comprehensive Synapse SDK guides and tutorials
- [Payments Overview](docs/payments-overview.md): Detailed explanation of the Payments system
- [Payment Rails](docs/payments/payment-rails.md): Documentation on payment rails
- [Integration Guide](docs/integration/pdp-payments.md): Guide for integrating PDP with Payments
- [System Diagrams](docs/diagrams.md): Visual representations of system architecture and workflows
- [Hot Vault Examples](docs/examples/hot-vault.md): Complete storage application examples
  - [Traditional Hot Vault](docs/examples/hot-vault.md): Docker-based reference implementation
  - [Wagmi-Vercel Hot Vault](docs/examples/wagmi-vercel-hotvault.md): Modern serverless Web3 application

## Deployed Contracts

**📋 Complete Contract Reference**: [Contracts Reference Guide](docs/contracts-reference.md)

### Quick Reference

**Filecoin Calibration Testnet** (for development):
- **PDP Verifier**: `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC`
- **Payments Contract**: `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A`
- **USDFC Token**: `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0`

**Filecoin Mainnet** (for production):
- **Payments Contract**: `0x8BA1f109551bD432803012645Ac136ddd64DBA72`

For complete contract information, ABIs, network configuration, and integration examples, see the [Contracts Reference Guide](docs/contracts-reference.md).
