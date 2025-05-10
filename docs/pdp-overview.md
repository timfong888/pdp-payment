# Understanding PDP (Provable Data Possession)

<<<<<<< HEAD
## Overview
=======
This document provides an overview of the Provable Data Possession (PDP) system in FilOz.

## What is PDP?
>>>>>>> update-payment-rate-docs

Provable Data Possession (PDP) is a cryptographic protocol that allows a client to verify that a storage provider still possesses the data they claim to be storing, without having to download the entire dataset. This is particularly important in decentralized storage networks like Filecoin, where clients need assurance that their data is being stored correctly.

## Key Components

<<<<<<< HEAD
### PDPVerifier Contract

The PDPVerifier contract is the core component of the PDP system. It:

- Manages proof sets for multiple clients and storage providers
- Generates challenges for storage providers to prove data possession
=======
The PDP system consists of several key components:

### PDPVerifier Contract

The PDPVerifier contract is the core component of the PDP system. It:
- Creates and manages proof sets
- Generates challenges for storage providers
>>>>>>> update-payment-rate-docs
- Verifies submitted proofs
- Tracks compliance with SLA terms

### SimplePDPService Contract

The SimplePDPService contract implements the SLA terms for the PDP system:
<<<<<<< HEAD

=======
>>>>>>> update-payment-rate-docs
- Defines proof frequency (maximum proving period)
- Specifies the challenge window during which proofs must be submitted
- Determines the number of challenges required per proof
- Records faults when proofs are missed or invalid

### Proof Sets

A proof set is a collection of data that a storage provider has committed to store:
<<<<<<< HEAD

=======
>>>>>>> update-payment-rate-docs
- Each proof set has a unique ID
- Contains references to the data being stored (CIDs)
- Tracks the owner (typically the storage provider)
- Records proof history and timing

## How PDP Works

1. **Proof Set Creation**: A client creates a proof set in the PDPVerifier contract, specifying:
   - The SLA contract to use (e.g., SimplePDPService)
   - Extra data containing their payment information

2. **Data Addition**: The storage provider adds data roots to the proof set, which represent the data they're storing.

3. **Challenge Generation**: The system generates random challenges based on the data in the proof set.

4. **Proof Submission**: The storage provider must submit valid proofs within specific time windows:
   - Proofs must be submitted during the challenge window (last 60 epochs of a proving period)
   - Each proof must respond to multiple challenges
   - Proofs are cryptographic evidence that the provider still has the data

5. **Verification**: The PDPVerifier contract verifies the submitted proofs:
   - Checks that the proofs are valid for the given challenges
   - Ensures proofs are submitted within the required timeframe

6. **Fault Recording**: If a storage provider fails to submit valid proofs on time:
   - The system records a fault
   - This information can be used by arbiters to adjust payments

## Integration with Payments

The PDP system integrates with the payments system through:

1. **Arbiter Contracts**: These contracts use fault records from the PDP system to determine payment adjustments.

2. **Payment Rails**: Payments flow from clients to storage providers through these rails, with adjustments based on PDP compliance.

3. **Settlement**: When a rail is settled, the arbiter can reduce payments for providers who have failed to meet their PDP obligations.

<<<<<<< HEAD
## Technical Details

### Proof Verification

Proofs are verified using Merkle proofs:

1. The storage provider maintains Merkle trees of the stored data
2. Challenges request specific leaves in these trees
3. The provider submits the leaf and a Merkle proof
4. The verifier checks that the proof is valid for the known Merkle root

### Timing Parameters

The default timing parameters in the SimplePDPService are:

- Maximum proving period: 2880 epochs (approximately 1 day on Filecoin)
- Challenge window: 60 epochs (last 60 epochs of the proving period)
- Challenges per proof: 5

### Security Considerations

The PDP system includes several security features:

- Challenge finality delay to prevent randomness manipulation
- Sybil fees to prevent spam attacks
- Proof fees to compensate for verification costs

## Next Steps

To learn how to use PDP in practice, see the [Creating Your First Storage Deal](first-deal.md) guide.
=======
## Deployed Contracts

The PDP service contract and the PDP verifier contracts are deployed on Filecoin Mainnet and Calibration Testnet.

**Mainnet**
- PDP Verifier: `0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6`
- PDP Service: `0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019`

**Calibration Testnet**
- PDP Verifier: `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC`
- PDP Service: `0x6170dE2b09b404776197485F3dc6c968Ef948505`

## Next Steps

- Learn more about [Creating a Proof Set](pdp/guides/creating-proof-set.md)
- Understand how to [Submit Proofs](pdp/guides/submitting-proofs.md)
- Explore the [Integration with Payments](integration/pdp-payments.md)
>>>>>>> update-payment-rate-docs
