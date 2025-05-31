# Contracts Integration Guide

This guide provides comprehensive information for developers who want to interact directly with the PDP and Payments smart contracts.

## Overview

The FilOz system consists of two main contract systems:

1. **PDP (Provable Data Possession) Contracts** - Handle storage verification and proof submission
2. **Payments Contracts** - Manage payment rails and settlement between clients and storage providers

## Contract Addresses

### Filecoin Calibration Testnet

| Contract | Address | Purpose |
|----------|---------|---------|
| **PDPVerifier** | `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC` | Main PDP verification contract |
| **SimplePDPService** | `0x6170dE2b09b404776197485F3dc6c968Ef948505` | PDP service implementation |
| **Payments** | `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A` | Payment rails management |
| **USDFC Token** | `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0` | Stablecoin for payments |

### Filecoin Mainnet

| Contract | Address | Purpose |
|----------|---------|---------|
| **Payments** | `0x8BA1f109551bD432803012645Ac136ddd64DBA72` | Payment rails management |

## Quick Start: Contract Interaction

### 1. Setup Web3 Connection

```javascript
const ethers = require('ethers');

// Connect to Filecoin Calibration testnet
const provider = new ethers.providers.JsonRpcProvider(
  'https://api.calibration.node.glif.io/rpc/v1'
);

// Create wallet instance
const wallet = new ethers.Wallet(privateKey, provider);
```

### 2. Contract Instances

```javascript
// PDP Verifier Contract
const pdpVerifierAbi = require('./abis/PDPVerifier.json');
const pdpVerifier = new ethers.Contract(
  '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC',
  pdpVerifierAbi,
  wallet
);

// Payments Contract
const paymentsAbi = require('./abis/Payments.json');
const payments = new ethers.Contract(
  '0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A',
  paymentsAbi,
  wallet
);

// USDFC Token Contract
const erc20Abi = [
  "function balanceOf(address owner) view returns (uint256)",
  "function approve(address spender, uint256 value) returns (bool)",
  "function transfer(address to, uint256 value) returns (bool)"
];
const usdfc = new ethers.Contract(
  '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0',
  erc20Abi,
  wallet
);
```

## PDP Contract Integration

### Creating a Proof Set

```javascript
async function createProofSet(railId, paymentsAddress) {
  try {
    // Encode payment information in extra data
    const extraData = ethers.utils.defaultAbiCoder.encode(
      ['uint256', 'address'],
      [railId, paymentsAddress]
    );
    
    // Get sybil fee (typically 0.1 tFIL)
    const sybilFee = await pdpVerifier.sybilFee();
    
    // Create proof set
    const tx = await pdpVerifier.createProofSet(
      '0x6170dE2b09b404776197485F3dc6c968Ef948505', // SimplePDPService address
      extraData,
      { value: sybilFee }
    );
    
    const receipt = await tx.wait();
    const proofSetId = receipt.events[0].args.setId;
    
    console.log(`Created proof set with ID: ${proofSetId}`);
    return proofSetId;
    
  } catch (error) {
    console.error('Error creating proof set:', error);
    throw error;
  }
}
```

### Submitting Proofs

```javascript
async function submitProofs(proofSetId, proofs) {
  try {
    // Check if it's time to submit proofs
    const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
    const currentEpoch = await provider.getBlockNumber();
    
    if (currentEpoch < nextChallengeEpoch) {
      console.log('Not yet time to submit proofs');
      return;
    }
    
    // Submit proofs
    const tx = await pdpVerifier.submitProofs(proofSetId, proofs);
    const receipt = await tx.wait();
    
    console.log(`Proofs submitted successfully: ${tx.hash}`);
    return receipt;
    
  } catch (error) {
    console.error('Error submitting proofs:', error);
    throw error;
  }
}
```

### Checking Proof Set Status

```javascript
async function getProofSetInfo(proofSetId) {
  try {
    const proofSet = await pdpVerifier.getProofSet(proofSetId);
    
    return {
      service: proofSet.service,
      owner: proofSet.owner,
      dataRootCount: proofSet.dataRootCount.toString(),
      lastProvenEpoch: proofSet.lastProvenEpoch.toString(),
      isActive: proofSet.isActive
    };
    
  } catch (error) {
    console.error('Error getting proof set info:', error);
    throw error;
  }
}
```

## Payments Contract Integration

### Creating a Payment Rail

```javascript
async function createPaymentRail(params) {
  try {
    const {
      tokenAddress,
      fromAddress,
      toAddress,
      arbiterAddress,
      paymentRate,
      lockupPeriod,
      lockupFixed,
      commissionRate
    } = params;
    
    // Create the payment rail
    const tx = await payments.createRail(
      tokenAddress,
      fromAddress,
      toAddress,
      arbiterAddress,
      paymentRate,
      lockupPeriod,
      lockupFixed,
      commissionRate
    );
    
    const receipt = await tx.wait();
    const railId = receipt.events[0].args.railId;
    
    console.log(`Created payment rail with ID: ${railId}`);
    return railId;
    
  } catch (error) {
    console.error('Error creating payment rail:', error);
    throw error;
  }
}
```

### Depositing Funds

```javascript
async function depositFunds(tokenAddress, amount) {
  try {
    const walletAddress = await wallet.getAddress();
    
    // First approve the payments contract to spend tokens
    const approveTx = await usdfc.approve(
      payments.address,
      ethers.utils.parseUnits(amount, 6) // USDFC has 6 decimals
    );
    await approveTx.wait();
    
    // Then deposit the funds
    const depositTx = await payments.deposit(
      tokenAddress,
      walletAddress,
      ethers.utils.parseUnits(amount, 6)
    );
    
    const receipt = await depositTx.wait();
    console.log(`Deposited ${amount} USDFC: ${depositTx.hash}`);
    return receipt;
    
  } catch (error) {
    console.error('Error depositing funds:', error);
    throw error;
  }
}
```

### Checking Account Balance

```javascript
async function getAccountBalance(tokenAddress, ownerAddress) {
  try {
    const account = await payments.accounts(tokenAddress, ownerAddress);
    
    return {
      funds: ethers.utils.formatUnits(account.funds, 6),
      lockupCurrent: ethers.utils.formatUnits(account.lockupCurrent, 6),
      lockupRate: ethers.utils.formatUnits(account.lockupRate, 6),
      lockupLastSettledAt: account.lockupLastSettledAt.toString()
    };
    
  } catch (error) {
    console.error('Error getting account balance:', error);
    throw error;
  }
}
```

## Error Handling Best Practices

### Common Error Scenarios

```javascript
async function safeContractCall(contractFunction, ...args) {
  try {
    const tx = await contractFunction(...args);
    const receipt = await tx.wait();
    
    if (receipt.status === 0) {
      throw new Error('Transaction failed');
    }
    
    return receipt;
    
  } catch (error) {
    // Handle specific error types
    if (error.code === 'INSUFFICIENT_FUNDS') {
      throw new Error('Insufficient funds for transaction');
    } else if (error.code === 'UNPREDICTABLE_GAS_LIMIT') {
      throw new Error('Transaction would fail - check contract state');
    } else if (error.message.includes('revert')) {
      throw new Error(`Contract reverted: ${error.message}`);
    }
    
    throw error;
  }
}
```

### Gas Estimation

```javascript
async function estimateGasAndExecute(contract, methodName, args, overrides = {}) {
  try {
    // Estimate gas
    const gasEstimate = await contract.estimateGas[methodName](...args, overrides);
    
    // Add 20% buffer
    const gasLimit = gasEstimate.mul(120).div(100);
    
    // Execute with estimated gas
    const tx = await contract[methodName](...args, {
      ...overrides,
      gasLimit
    });
    
    return await tx.wait();
    
  } catch (error) {
    console.error('Gas estimation failed:', error);
    throw error;
  }
}
```

## Integration Examples

### Complete Storage + Payment Flow

```javascript
async function completeStorageFlow(fileSize, storageProvider) {
  try {
    // 1. Calculate payment parameters
    const sizeInMB = fileSize / (1024 * 1024);
    const paymentRate = ethers.utils.parseUnits((sizeInMB * 0.01).toString(), 6); // 0.01 USDFC per MB per epoch
    
    // 2. Create payment rail
    const railId = await createPaymentRail({
      tokenAddress: '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0',
      fromAddress: await wallet.getAddress(),
      toAddress: storageProvider,
      arbiterAddress: '0x6170dE2b09b404776197485F3dc6c968Ef948505',
      paymentRate,
      lockupPeriod: 60, // 60 epochs
      lockupFixed: ethers.utils.parseUnits('1', 6), // 1 USDFC
      commissionRate: 0
    });
    
    // 3. Create proof set
    const proofSetId = await createProofSet(railId, payments.address);
    
    // 4. Return both IDs for tracking
    return { railId, proofSetId };
    
  } catch (error) {
    console.error('Complete storage flow failed:', error);
    throw error;
  }
}
```

## Next Steps

- **For SDK Integration**: See [Synapse SDK Documentation](sdk/sdk-quickstart.md)
- **For Hot Vault Demo**: See [Hot Vault Example](examples/hot-vault.md)
- **For Modern Web3 Apps**: See [Wagmi-Vercel Hot Vault](examples/wagmi-vercel-hotvault.md)
- **For Payment Details**: See [Payments Overview](payments-overview.md)
- **For PDP Details**: See [PDP Overview](pdp-overview.md)

## Support

For technical support and questions:
- **GitHub Issues**: [pdp-payment repository](https://github.com/timfong888/pdp-payment/issues)
- **Documentation**: [Complete documentation index](navigation.md)
