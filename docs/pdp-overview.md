# Understanding PDP (Provable Data Possession)

## Overview

Provable Data Possession (PDP) is a cryptographic protocol that allows a client to verify that a storage provider still possesses the data they claim to be storing, without having to download the entire dataset. This is particularly important in decentralized storage networks like Filecoin, where clients need assurance that their data is being stored correctly.

## Key Components

### PDPVerifier Contract

The PDPVerifier contract is the core component of the PDP system. It:

- Manages proof sets for multiple clients and storage providers
- Generates challenges for storage providers to prove data possession
- Verifies submitted proofs
- Tracks compliance with SLA terms

### SimplePDPService Contract

The SimplePDPService contract implements the SLA terms for the PDP system:

- Defines proof frequency (maximum proving period)
- Specifies the challenge window during which proofs must be submitted
- Determines the number of challenges required per proof
- Records faults when proofs are missed or invalid

### Proof Sets

A proof set is a collection of data that a storage provider has committed to store:

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
