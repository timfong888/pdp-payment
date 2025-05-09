# Creating a Proof Set

This guide explains how to create a proof set in the PDP system, which is the first step in verifying data possession.

## Prerequisites

- An Ethereum wallet with some ETH for gas
- The address of the PDPVerifier contract
- The address of the PDPService contract (e.g., SimplePDPService)

## Step 1: Connect to the PDPVerifier Contract

First, connect to the PDPVerifier contract:

```javascript
const ethers = require('ethers');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

// Connect to the provider
const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
const wallet = new ethers.Wallet(privateKey, provider);

// PDPVerifier contract address on Calibration Testnet
const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC';

// Create contract instance
const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, wallet);
```

## Step 2: Prepare Extra Data

The extra data is a crucial component that allows for extending the basic proof set with additional metadata. In this example, we'll include payment information:

```javascript
// Encode payment information in the extra data
const extraData = ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address'],
    [railId, paymentsContractAddress]
);
```

If you're not using the Payments system, you can provide an empty byte array:

```javascript
const extraData = '0x';
```

## Step 3: Calculate the Sybil Fee

The PDPVerifier requires a sybil fee to prevent spam attacks:

```javascript
// Get the current sybil fee
const sybilFee = await pdpVerifier.sybilFee();
console.log(`Sybil fee: ${ethers.utils.formatEther(sybilFee)} ETH`);
```

## Step 4: Create the Proof Set

Now, create the proof set by calling the `createProofSet` function:

```javascript
// PDPService contract address on Calibration Testnet
const pdpServiceAddress = '0x6170dE2b09b404776197485F3dc6c968Ef948505';

// Create the proof set
const tx = await pdpVerifier.createProofSet(
    pdpServiceAddress, // The SLA contract address
    extraData,         // The extra data
    { value: sybilFee } // Pay the sybil fee
);

// Wait for the transaction to be mined
const receipt = await tx.wait();

// Get the proof set ID from the event logs
const proofSetId = receipt.events[0].args.setId;
console.log(`Created proof set with ID: ${proofSetId}`);
```

## Step 5: Verify the Proof Set Creation

You can verify that the proof set was created successfully:

```javascript
// Check if the proof set is live
const isLive = await pdpVerifier.proofSetLive(proofSetId);
console.log(`Proof set is live: ${isLive}`);

// Get the proof set owner
const [owner, proposedOwner] = await pdpVerifier.getProofSetOwner(proofSetId);
console.log(`Proof set owner: ${owner}`);

// Get the proof set listener (SLA contract)
const listener = await pdpVerifier.getProofSetListener(proofSetId);
console.log(`Proof set listener: ${listener}`);
```

## Complete Example

Here's a complete example of creating a proof set:

```javascript
const ethers = require('ethers');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

async function createProofSet() {
    // Connect to the provider
    const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
    const wallet = new ethers.Wallet(privateKey, provider);
    
    // PDPVerifier contract address on Calibration Testnet
    const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC';
    
    // Create contract instance
    const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, wallet);
    
    // PDPService contract address on Calibration Testnet
    const pdpServiceAddress = '0x6170dE2b09b404776197485F3dc6c968Ef948505';
    
    // Encode payment information in the extra data (if using Payments)
    const extraData = ethers.utils.defaultAbiCoder.encode(
        ['uint256', 'address'],
        [railId, paymentsContractAddress]
    );
    
    // Get the current sybil fee
    const sybilFee = await pdpVerifier.sybilFee();
    console.log(`Sybil fee: ${ethers.utils.formatEther(sybilFee)} ETH`);
    
    // Create the proof set
    const tx = await pdpVerifier.createProofSet(
        pdpServiceAddress,
        extraData,
        { value: sybilFee }
    );
    
    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    
    // Get the proof set ID from the event logs
    const proofSetId = receipt.events[0].args.setId;
    console.log(`Created proof set with ID: ${proofSetId}`);
    
    // Verify the proof set creation
    const isLive = await pdpVerifier.proofSetLive(proofSetId);
    console.log(`Proof set is live: ${isLive}`);
    
    return proofSetId;
}

createProofSet()
    .then(proofSetId => console.log(`Proof set created with ID: ${proofSetId}`))
    .catch(error => console.error(`Error creating proof set: ${error}`));
```

## Next Steps

After creating a proof set, you'll need to:

1. [Add data to the proof set](adding-data.md)
2. [Submit proofs](submitting-proofs.md) to demonstrate data possession
3. [Verify proofs](verifying-proofs.md) to ensure data is being stored correctly

For a complete example of using proof sets in a real application, see the [Hot Vault Demo](../../examples/hot-vault.md).
