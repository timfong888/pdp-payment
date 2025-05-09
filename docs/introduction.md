# Introduction to FilOz

## What is FilOz?

FilOz is a comprehensive ecosystem of tools and smart contracts designed to enhance the Filecoin storage network. It focuses on providing provable data possession (PDP), payment mechanisms, and tools for both storage providers and clients.

## Core Components

### PDP (Provable Data Possession)

The PDP system allows storage providers to prove they are still storing client data without having to retrieve the entire dataset. This is accomplished through:

- **PDPVerifier Contract**: Handles the verification of proofs submitted by storage providers
- **SimplePDPService**: Implements the SLA (Service Level Agreement) terms for proof frequency and requirements
- **Proof Sets**: Data structures that track the data being proven, the owner, and proof history

### Payments System

The payments system provides flexible payment channels between clients and storage providers:

- **Payment Rails**: Channels that connect payers and payees with configurable payment rates
- **Arbitration**: Third-party arbiters that can modify payment amounts based on service delivery
- **Settlement**: Process for ensuring payments are made according to agreed terms

### Client Contract

The client contract facilitates the creation of storage deals on Filecoin:

- **Deal Proposals**: Creation of storage deal proposals with specific parameters
- **Deal Management**: Tracking and management of deal status
- **Integration with Filecoin**: Interaction with the Filecoin storage market

### Explorer and Tools

- **PDP Explorer**: Web interface for monitoring PDP proofs and storage provider performance
- **FilForwarder**: Tool for forwarding deals to storage providers
- **DAGParts**: Library for working with content-addressable data

## How It All Works Together

1. **Client Initiates Storage**: A client creates a deal proposal through the Client Contract, specifying parameters like price, duration, and data location.

2. **PDP Integration**: The client creates a proof set in the PDPVerifier contract, specifying which SLA contract to use and providing signed payment information.

3. **Storage Provider Stores Data**: The storage provider retrieves the data from the specified location and begins storing it.

4. **Ongoing Verification**: The PDP system periodically challenges the storage provider to prove they still have the data.

5. **Payment Processing**: The payment rails, connected via the arbiter, adjust payments based on the provider's performance against the SLA.

## Benefits of FilOz

- **Trustless Verification**: Cryptographic proofs ensure data is being stored without requiring trust
- **Flexible Payments**: Configurable payment channels with arbitration for SLA enforcement
- **Transparency**: Explorer tools provide visibility into storage provider performance
- **Integration**: Seamless integration with the Filecoin network

## Next Steps

To start using FilOz, proceed to the [Setting Up Your Environment](setup.md) guide.
