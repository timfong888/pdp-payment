# Documentation Navigation Guide

This comprehensive index helps you find the right documentation for your needs, organized by user type and common tasks.

## 🚀 Quick Start Paths

### For Beginners
**Goal: Get started with minimal setup**
1. [Setup Wallet & USDFC](setup.md) - Get testnet tokens
2. [Quick Start with SDK](quick-start.md) - Use the Synapse SDK
3. [Hot Vault Example](examples/hot-vault.md) - See it in action

### For Developers
**Goal: Build production applications**
1. [Setup Wallet & USDFC](setup.md) - Get testnet tokens
2. [Blockchain Configuration](setup-detailed.md) - JSON-RPC, Viem patterns
3. [Contract Integration](contracts-guide.md) - Direct contract calls
4. [Advanced Examples](examples/wagmi-vercel-hotvault.md) - Modern Web3 patterns

### For Advanced Users
**Goal: Deep customization and integration**
1. [Contracts Guide](contracts-guide.md) - Direct contract interaction
2. [PDP Overview](pdp-overview.md) - Understand the proof system
3. [Payments Overview](payments-overview.md) - Payment rail mechanics
4. [Integration Guide](integration/pdp-payments.md) - Custom implementations

## 📚 Documentation by Category

### 🔧 Setup & Configuration
- **[Setup Wallet & USDFC](setup.md)** - Initial wallet setup and testnet tokens
- **[Blockchain Configuration](setup-detailed.md)** - JSON-RPC, Viem patterns, environment setup
- **[Quick Start](quick-start.md)** - Get started with the Synapse SDK

### 🏗️ Core Systems
- **[PDP Overview](pdp-overview.md)** - Provable Data Possession system
- **[Payments Overview](payments-overview.md)** - Payment rails and settlement
- **[Payment Rails](payments/payment-rails.md)** - Detailed payment rail documentation
- **[Contracts Guide](contracts-guide.md)** - Direct smart contract integration

### 🛠️ Development Tools
- **[Synapse SDK](sdk/sdk-quickstart.md)** - High-level SDK for rapid development
- **[SDK Workflow](sdk/sdk-workflow.md)** - SDK development patterns
- **[SDK Production](sdk/sdk-production.md)** - Production deployment with SDK
- **[SDK Monitoring](sdk/sdk-monitoring.md)** - Monitoring and debugging

### 💡 Examples & Tutorials
- **[Hot Vault (Traditional)](examples/hot-vault.md)** - Docker-based reference implementation
- **[Wagmi-Vercel Hot Vault](examples/wagmi-vercel-hotvault.md)** - Modern serverless Web3 app
- **[Integration Examples](integration/pdp-payments.md)** - PDP + Payments integration patterns

### 🔗 Integration Guides
- **[PDP-Payments Integration](integration/pdp-payments.md)** - Combine storage proofs with payments
- **[Building on FilOz](integration/building-on-filoz.md)** - Platform integration guide
- **[Filecoin Ecosystem](integration/filecoin-ecosystem.md)** - Broader ecosystem context

## 🎯 Common Tasks

### Setting Up Storage
1. **Choose your approach:**
   - **SDK (Recommended)**: [Synapse SDK Quickstart](sdk/sdk-quickstart.md)
   - **Direct Contracts**: [Contracts Guide](contracts-guide.md)
2. **Setup environment**: [Blockchain Configuration](setup-detailed.md)
3. **Follow examples**: [Hot Vault Demo](examples/hot-vault.md)

### Creating Payment Rails
1. **Understand concepts**: [Payments Overview](payments-overview.md)
2. **Learn payment rails**: [Payment Rails Guide](payments/payment-rails.md)
3. **See examples**: [Contract Integration](contracts-guide.md#payments-contract-integration)

### Implementing Proofs
1. **Understand PDP**: [PDP Overview](pdp-overview.md)
2. **Contract integration**: [Contracts Guide](contracts-guide.md#pdp-contract-integration)
3. **Production patterns**: [SDK Production Guide](sdk/sdk-production.md)

### Deploying Applications
1. **Traditional approach**: [Hot Vault Example](examples/hot-vault.md)
2. **Modern serverless**: [Wagmi-Vercel Hot Vault](examples/wagmi-vercel-hotvault.md)
3. **Production considerations**: [SDK Production](sdk/sdk-production.md)

## 🔍 Search by Keywords

### Storage & Files
- [PDP Overview](pdp-overview.md) - proof verification, data possession
- [Hot Vault Examples](examples/hot-vault.md) - file upload, storage dashboard
- [Contracts Guide](contracts-guide.md) - proof sets, verification

### Payments & Economics
- [Payments Overview](payments-overview.md) - payment rails, settlement, arbitration
- [Payment Rails](payments/payment-rails.md) - lockup, rates, commission
- [Integration Guide](integration/pdp-payments.md) - payment + storage integration

### Web3 & Blockchain
- [Setup Detailed](setup-detailed.md) - JSON-RPC, Viem, wallet connection
- [Wagmi-Vercel Hot Vault](examples/wagmi-vercel-hotvault.md) - modern Web3 patterns
- [Contracts Guide](contracts-guide.md) - smart contracts, transactions

### Development & Deployment
- [SDK Documentation](sdk/sdk-quickstart.md) - rapid development, TypeScript
- [Wagmi-Vercel Hot Vault](examples/wagmi-vercel-hotvault.md) - serverless, Vercel
- [SDK Production](sdk/sdk-production.md) - production deployment

## 📊 Documentation Status

### ✅ Complete & Current
- Setup guides (wallet, blockchain configuration)
- Core system overviews (PDP, Payments)
- SDK documentation
- Example implementations
- Contract integration guides

### 🔄 Recently Updated
- Hot Vault examples with cross-references
- Wagmi-Vercel modern implementation
- Contract addresses and ABIs
- Navigation and organization

### 📋 Reference Materials
- [Contracts Reference](contracts-reference.md) - Contract addresses, ABIs, deployment info
- [System Diagrams](diagrams.md) - Visual system architecture
- [Deployed Contracts](../README.md#deployed-contracts) - Live contract addresses

## 🆘 Getting Help

### Documentation Issues
- **Missing information?** Check if it's covered in related sections
- **Outdated content?** Contract addresses and examples are regularly updated
- **Need clarification?** Look for cross-references to related topics

### Technical Support
- **SDK Issues**: Start with [SDK Quickstart](sdk/sdk-quickstart.md)
- **Contract Problems**: See [Contracts Guide](contracts-guide.md) error handling
- **Integration Questions**: Check [Integration Guide](integration/pdp-payments.md)

### Community Resources
- **GitHub Repository**: [pdp-payment](https://github.com/timfong888/pdp-payment)
- **Example Code**: [Hot Vault Demo](https://github.com/FilOzone/hotvault-demo)
- **SDK Repository**: [Synapse SDK](https://github.com/FilOzone/synapse-sdk)

## 🗺️ Documentation Map

```
docs/
├── 🚀 Getting Started
│   ├── setup.md (wallet & tokens)
│   ├── setup-detailed.md (blockchain config)
│   └── quick-start.md (SDK quickstart)
├── 🏗️ Core Systems
│   ├── pdp-overview.md (proof system)
│   ├── payments-overview.md (payment rails)
│   └── contracts-guide.md (direct integration)
├── 🛠️ SDK Documentation
│   ├── sdk/sdk-quickstart.md
│   ├── sdk/sdk-workflow.md
│   ├── sdk/sdk-production.md
│   └── sdk/sdk-monitoring.md
├── 💡 Examples
│   ├── examples/hot-vault.md (traditional)
│   └── examples/wagmi-vercel-hotvault.md (modern)
├── 🔗 Integration
│   ├── integration/pdp-payments.md
│   ├── integration/building-on-filoz.md
│   └── integration/filecoin-ecosystem.md
├── 📋 Reference
│   ├── contracts-reference.md
│   ├── payments/payment-rails.md
│   └── diagrams.md
└── 🗺️ Navigation
    └── navigation.md (this file)
```

---

**💡 Tip**: Bookmark this page for quick access to all documentation. Use Ctrl+F (Cmd+F) to search for specific topics.
