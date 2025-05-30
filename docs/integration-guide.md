# Integrating PDP with Payments

This guide explains how to integrate the [Provable Data Possession (PDP)](pdp-overview.md) system with the [Payments](payments-overview.md) system to create a complete solution for verifiable storage with automatic payment adjustments based on service level compliance.

## Overview

The integration between PDP and Payments enables:

1. **Verifiable Storage**: Clients can verify that storage providers are actually storing their data
2. **Automatic Payment Adjustments**: Payments are automatically adjusted based on proof compliance
3. **SLA Enforcement**: Service Level Agreements are enforced through the arbitration mechanism
4. **Continuous Payment Flow**: Payments flow continuously as long as the service is provided correctly

## Integration Architecture

The integration works through these key components:

1. **Payment Rails**: Created in the Payments contract to facilitate ongoing payments
2. **Proof Sets**: Created in the PDP system to verify data possession
3. **Arbiter Contract**: Connects the two systems by adjusting payments based on proof compliance
4. **Extra Data**: Links the proof set to the payment rail

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Client    │◄────►│  Payments   │◄────►│   Arbiter   │
└─────────────┘      └─────────────┘      └─────────────┘
       ▲                                         ▲
       │                                         │
       ▼                                         ▼
┌─────────────┐                          ┌─────────────┐
│ Storage     │◄────────────────────────►│     PDP     │
│ Provider    │                          │   System    │
└─────────────┘                          └─────────────┘
```

## Step-by-Step Integration Guide

### 1. Create a Payment Rail

First, create a payment rail in the Payments contract:

```javascript
// Using ethers.js to create a payment rail
async function createPaymentRail() {
    const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDC per epoch
    const lockupPeriod = 2880; // 1 day in epochs (assuming 30-second epochs)
    const lockupFixed = ethers.utils.parseUnits('5', 6); // 5 USDC fixed lockup
    const commissionRate = 250; // 2.5% commission
    
    const tx = await payments.createRail(
        tokenAddress,
        clientAddress,
        providerAddress,
        arbiterAddress, // Address of your PDP arbiter contract
        paymentRate,
        lockupPeriod,
        lockupFixed,
        commissionRate
    );
    
    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    
    // Get the rail ID from the event logs
    const railId = receipt.events[0].args.railId;
    console.log(`Created rail with ID: ${railId}`);
    
    return railId;
}
```

### 2. Create a Proof Set with Payment Information

Next, create a proof set in the PDP system, including the payment rail information in the extra data:

```javascript
// Create a proof set with payment information
async function createProofSet(railId) {
    // Encode the payment information in the extra data
    const extraData = ethers.utils.defaultAbiCoder.encode(
        ['uint256', 'address'],
        [railId, paymentsContractAddress]
    );
    
    // Calculate the sybil fee
    const sybilFee = await pdpVerifier.sybilFee();
    
    // Create a proof set
    const tx = await pdpVerifier.createProofSet(
        pdpServiceAddress, // Address of the SimplePDPService contract
        extraData,
        { value: sybilFee }
    );
    
    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    
    // Get the proof set ID from the event logs
    const proofSetId = receipt.events[0].args.setId;
    console.log(`Created proof set with ID: ${proofSetId}`);
    
    return proofSetId;
}
```

### 3. Implement a PDP Arbiter

Create an arbiter contract that adjusts payments based on PDP compliance:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IArbiter.sol";
import "./IPDPService.sol";

contract PDPArbiter is IArbiter {
    IPDPService public pdpService;
    mapping(uint256 => uint256) public railToProofSet;
    
    constructor(address _pdpService) {
        pdpService = IPDPService(_pdpService);
    }
    
    // Register a rail-to-proof-set mapping
    function registerRailProofSet(uint256 railId, uint256 proofSetId) external {
        // Add appropriate access control here
        railToProofSet[railId] = proofSetId;
    }
    
    function arbitratePayment(
        address token,
        address from,
        address to,
        uint256 railId,
        uint256 fromEpoch,
        uint256 toEpoch,
        uint256 amount
    ) external view override returns (ArbitrationResult memory) {
        // Get the proof set ID for this rail
        uint256 proofSetId = railToProofSet[railId];
        
        // If no proof set is registered, return the original amount
        if (proofSetId == 0) {
            return ArbitrationResult({
                modifiedAmount: amount,
                settleUpto: toEpoch,
                note: "No proof set registered"
            });
        }
        
        // Get fault count from PDP service
        uint256 faultCount = pdpService.getFaultCount(proofSetId, fromEpoch, toEpoch);
        
        // Calculate reduction (10% per fault, up to 100%)
        uint256 reductionPercent = faultCount * 10;
        if (reductionPercent > 100) reductionPercent = 100;
        
        uint256 reduction = amount * reductionPercent / 100;
        uint256 modifiedAmount = amount - reduction;
        
        return ArbitrationResult({
            modifiedAmount: modifiedAmount,
            settleUpto: toEpoch,
            note: string(abi.encodePacked("Reduced by ", faultCount, " faults"))
        });
    }
}
```

### 4. Storage Provider: Add Data to the Proof Set

The storage provider adds data to the proof set:

```javascript
// Add data to the proof set
async function addRoots(proofSetId, cid, dataSize) {
    // Prepare the root data
    const rootData = [
        {
            root: {
                version: 1,
                codec: 0x71, // dag-cbor
                hash: 0x12, // sha2-256
                size: 32,
                data: rootCidBytes
            },
            rawSize: dataSize
        }
    ];
    
    // Add roots to the proof set
    const tx = await pdpVerifier.addRoots(
        proofSetId,
        rootData,
        "0x" // No extra data needed
    );
    
    // Wait for the transaction to be mined
    await tx.wait();
}
```

### 5. Storage Provider: Submit Proofs

The storage provider submits proofs regularly:

```javascript
// Submit proofs to the PDP system
async function submitProofs(proofSetId) {
    // Get the next challenge epoch
    const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
    
    // Wait until the challenge epoch
    // ... (implementation depends on your environment)
    
    // Generate proofs for the challenges
    const proofs = await generateProofs(proofSetId);
    
    // Submit proofs
    const proofFee = await pdpVerifier.calculateProofFee(proofSetId, estimatedGasFee);
    const tx = await pdpVerifier.provePossession(
        proofSetId,
        proofs,
        { value: proofFee }
    );
    
    // Wait for the transaction to be mined
    await tx.wait();
}
```

### 6. Settle Payments

Payments can be settled by anyone, typically the payee:

```javascript
// Settle payments
async function settlePayments(railId) {
    // Settle payments up to the current epoch
    const currentEpoch = await provider.getBlockNumber();
    await payments.settleRail(railId, currentEpoch);
}
```

## Complete Integration Example

Here's a complete example that ties all the steps together:

```javascript
async function setupPDPPaymentIntegration() {
    // Step 1: Create a payment rail
    const railId = await createPaymentRail();
    
    // Step 2: Create a proof set with payment information
    const proofSetId = await createProofSet(railId);
    
    // Step 3: Register the rail-to-proof-set mapping in the arbiter
    await pdpArbiter.registerRailProofSet(railId, proofSetId);
    
    // Step 4: Storage provider adds data to the proof set
    await addRoots(proofSetId, cid, dataSize);
    
    // Step 5: Set up a recurring task to submit proofs
    // This would typically be implemented as a cron job or similar
    setInterval(async () => {
        try {
            await submitProofs(proofSetId);
            console.log("Proofs submitted successfully");
        } catch (error) {
            console.error("Error submitting proofs:", error);
        }
    }, 86400000); // Check daily
    
    // Step 6: Set up a recurring task to settle payments
    // This would typically be implemented as a cron job or similar
    setInterval(async () => {
        try {
            await settlePayments(railId);
            console.log("Payments settled successfully");
        } catch (error) {
            console.error("Error settling payments:", error);
        }
    }, 86400000); // Settle daily
    
    return { railId, proofSetId };
}
```

## Best Practices

1. **Secure Extra Data**: Ensure that the extra data containing payment information is properly secured and verified
2. **Regular Settlement**: Settle payments regularly to ensure timely compensation for storage providers
3. **Fault Monitoring**: Monitor fault records to identify and address issues promptly
4. **Arbiter Security**: Implement proper access controls in your arbiter contract
5. **Testing**: Thoroughly test the integration on a testnet before deploying to mainnet

## Next Steps

- Follow the [Quick Start Guide](quick-start.md) to get started with implementation
- Explore the [Hot Vault Example](examples/hot-vault.md) for a complete implementation
- Learn about the [PDP System](pdp-overview.md) and [Payments System](payments-overview.md) in more detail
