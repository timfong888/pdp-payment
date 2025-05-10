# PDP Overview

## What is Provable Data Possession (PDP)?

Provable Data Possession (PDP) is a cryptographic protocol that allows a client to verify that a storage provider still possesses the data they claim to be storing, without having to download the entire dataset. This is particularly important in decentralized storage networks like Filecoin, where clients need assurance that their data is being stored correctly over time.

The FilOz PDP system provides a robust implementation of this protocol on the Filecoin network, enabling verifiable storage with customizable Service Level Agreements (SLAs).

## Key Features

- **Efficient Verification**: Verify data possession without retrieving the entire dataset
- **Customizable SLAs**: Define specific proof frequency and requirements
- **Fault Detection**: Automatically detect when storage providers fail to prove possession
- **Integration with Payments**: Connect proof compliance with payment adjustments
- **Scalable Architecture**: Handle multiple proof sets and storage providers

## Core Components

The PDP system consists of several key components:

### [PDPVerifier Contract](../api/verifier-contract.md)

The central contract that manages proof sets and verifies proofs. It:
- Creates and manages proof sets
- Generates challenges for storage providers
- Verifies submitted proofs
- Tracks compliance with SLA terms

```solidity
function createProofSet(address listenerAddr, bytes calldata extraData) public payable returns (uint256)
```

### [SimplePDPService Contract](../api/service-contract.md)

Implements the SLA terms for the PDP system:
- Defines proof frequency (maximum proving period)
- Specifies the challenge window during which proofs must be submitted
- Determines the number of challenges required per proof
- Records faults when proofs are missed or invalid

```solidity
function getMaxProvingPeriod() public pure returns (uint64) {
    return 2880; // Maximum epochs between proofs (approximately 1 day)
}
```

### [PDPListener Interface](../api/listener-interface.md)

An interface that allows for extensible applications to use the PDP verification contract:
- Notifies when proof sets are created or deleted
- Reports when roots are added or scheduled for removal
- Informs when possession is proven
- Signals the start of a new proving period

```solidity
interface PDPListener {
    function proofSetCreated(uint256 proofSetId, address creator, bytes calldata extraData) external;
    function possessionProven(uint256 proofSetId, uint256 challengedLeafCount, uint256 seed, uint256 challengeCount) external;
    // Additional functions...
}
```

## How It Works

The PDP system works through a series of steps:

1. **[Creating a Proof Set](../guides/creating-proof-set.md)**: A client creates a proof set in the PDPVerifier contract, specifying which SLA contract to use and providing signed payment information.

2. **Adding Data**: The storage provider adds data roots to the proof set, which represent the data they're storing.

3. **Challenge Generation**: The system generates random challenges based on the data in the proof set.

4. **[Submitting Proofs](../guides/submitting-proofs.md)**: The storage provider must submit valid proofs within specific time windows.

5. **[Verification](../guides/verifying-proofs.md)**: The PDPVerifier contract verifies the submitted proofs.

6. **[Fault Recording](../guides/handling-faults.md)**: If a storage provider fails to submit valid proofs on time, the system records a fault.

7. **Payment Adjustment**: The [arbitration system](../../payments/concepts/arbitration.md) uses fault records to adjust payments on the [payment rail](../../payments/concepts/payment-rails.md).

## Integration with Payments

The PDP system integrates with the [Payments system](../../payments/concepts/overview.md) through:

1. **[Arbiter Contracts](../../payments/concepts/arbitration.md)**: These contracts use fault records from the PDP system to determine payment adjustments.

2. **[Payment Rails](../../payments/concepts/payment-rails.md)**: Payments flow from clients to storage providers through these rails, with adjustments based on PDP compliance.

3. **[Settlement](../../payments/concepts/settlement.md)**: When a rail is settled, the arbiter can reduce payments for providers who have failed to meet their PDP obligations.

For a detailed guide on integrating PDP with Payments, see [Integrating PDP with Payments](../../integration/pdp-payments.md).

## Deployed Contracts

The PDP service contract and the PDP verifier contracts are deployed on Filecoin Mainnet and Calibration Testnet.

> Disclaimer: ⚠️ These contracts are still under beta testing and might be upgraded for bug fixes and/or improvements. Please use with caution for production environments. ⚠️

**Mainnet**
- [PDP Verifier](https://filfox.info/en/address/0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6): `0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6`
- [PDP Service](https://filfox.info/en/address/0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019): `0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019`

**Calibration Testnet**
- [PDP Verifier](https://calibration.filfox.info/en/address/0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC): `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC`
- [PDP Service](https://calibration.filfox.info/en/address/0x6170dE2b09b404776197485F3dc6c968Ef948505): `0x6170dE2b09b404776197485F3dc6c968Ef948505` (Note: This has a proving period every 30 minutes instead of every day)

## Security Considerations

The PDP system includes several security features:

- **Challenge Finality Delay**: Prevents randomness manipulation by storage providers
- **Sybil Fees**: Prevents spam attacks on the system
- **Proof Fees**: Compensates for verification costs
- **Cryptographic Verification**: Ensures proofs are valid and correspond to the correct data

For more details on the security model, see [PDP Security Model](security.md).

## Next Steps

- Learn [How PDP Works](how-it-works.md) in detail
- Explore the [PDP Components](components.md)
- Follow the guide for [Creating a Proof Set](../guides/creating-proof-set.md)
- Understand how to [Submit Proofs](../guides/submitting-proofs.md)
- See a complete example in the [Hot Vault Demo](../../examples/hot-vault.md)
