# Submitting Proofs

This guide explains how to submit proofs of data possession to the PDP system, which is a key step in demonstrating that you are still storing the data.

## Prerequisites

- An Ethereum wallet with some ETH for gas
- A proof set ID from [creating a proof set](creating-proof-set.md)
- Data added to the proof set (see [adding data](adding-data.md))
- The PDP Tool for generating proofs

## Step 1: Install the PDP Tool

The PDP Tool is required to generate proofs. You can install it from the [Curio repository](https://github.com/filecoin-project/curio/tree/feat/pdp):

```bash
git clone -b feat/pdp https://github.com/filecoin-project/curio.git
cd curio
make pdp
```

## Step 2: Check When to Submit Proofs

Before submitting proofs, you need to check if it's time to do so:

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

// Check the next challenge epoch
const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
const currentEpoch = await provider.getBlockNumber();

console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
console.log(`Current epoch: ${currentEpoch}`);

if (currentEpoch >= nextChallengeEpoch) {
    console.log('It is time to submit proofs!');
} else {
    console.log(`Wait ${nextChallengeEpoch - currentEpoch} more epochs before submitting proofs.`);
}
```

## Step 3: Generate Proofs

To generate proofs, you'll need to use the PDP Tool. Here's a simplified example:

```bash
# Export environment variables
export PROOF_SET_ID=your_proof_set_id
export PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
export RPC_URL=https://calibration.filfox.info/rpc/v1
export PRIVATE_KEY=your_private_key

# Generate proofs
pdp prove --proof-set-id $PROOF_SET_ID --verifier-address $PDP_VERIFIER_ADDRESS --rpc-url $RPC_URL
```

This will generate a JSON file containing the proofs.

## Step 4: Submit Proofs

Once you have generated the proofs, you can submit them to the PDPVerifier contract:

```javascript
const fs = require('fs');
const ethers = require('ethers');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

// Connect to the provider
const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
const wallet = new ethers.Wallet(privateKey, provider);

// PDPVerifier contract address on Calibration Testnet
const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC';

// Create contract instance
const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, wallet);

// Load the proofs from the JSON file
const proofsJson = fs.readFileSync('./proofs.json', 'utf8');
const proofs = JSON.parse(proofsJson);

// Calculate the proof fee
const estimatedGasFee = 1000000; // Estimate gas fee (adjust as needed)
const proofFee = await pdpVerifier.calculateProofFee(proofSetId, estimatedGasFee);

console.log(`Proof fee: ${ethers.utils.formatEther(proofFee)} ETH`);

// Submit the proofs
const tx = await pdpVerifier.provePossession(
    proofSetId,
    proofs,
    { value: proofFee }
);

// Wait for the transaction to be mined
const receipt = await tx.wait();

console.log(`Proofs submitted in transaction: ${receipt.transactionHash}`);
```

## Step 5: Verify Proof Submission

You can verify that the proofs were submitted successfully:

```javascript
// Get the last proven epoch
const lastProvenEpoch = await pdpVerifier.getProofSetLastProvenEpoch(proofSetId);
console.log(`Last proven epoch: ${lastProvenEpoch}`);

// Check if the next challenge epoch has been updated
const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
```

## Complete Example

Here's a complete example of checking when to submit proofs and submitting them:

```javascript
const fs = require('fs');
const ethers = require('ethers');
const { exec } = require('child_process');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

async function submitProofs(proofSetId) {
    // Connect to the provider
    const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
    const wallet = new ethers.Wallet(privateKey, provider);
    
    // PDPVerifier contract address on Calibration Testnet
    const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC';
    
    // Create contract instance
    const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, wallet);
    
    // Check the next challenge epoch
    const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
    const currentEpoch = await provider.getBlockNumber();
    
    console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
    console.log(`Current epoch: ${currentEpoch}`);
    
    if (currentEpoch < nextChallengeEpoch) {
        console.log(`Wait ${nextChallengeEpoch - currentEpoch} more epochs before submitting proofs.`);
        return;
    }
    
    console.log('Generating proofs...');
    
    // Generate proofs using the PDP Tool
    const command = `pdp prove --proof-set-id ${proofSetId} --verifier-address ${pdpVerifierAddress} --rpc-url https://calibration.filfox.info/rpc/v1`;
    
    exec(command, async (error, stdout, stderr) => {
        if (error) {
            console.error(`Error generating proofs: ${error}`);
            return;
        }
        
        console.log('Proofs generated successfully!');
        
        // Load the proofs from the JSON file
        const proofsJson = fs.readFileSync(`./proofs_${proofSetId}.json`, 'utf8');
        const proofs = JSON.parse(proofsJson);
        
        // Calculate the proof fee
        const estimatedGasFee = 1000000; // Estimate gas fee (adjust as needed)
        const proofFee = await pdpVerifier.calculateProofFee(proofSetId, estimatedGasFee);
        
        console.log(`Proof fee: ${ethers.utils.formatEther(proofFee)} ETH`);
        
        // Submit the proofs
        const tx = await pdpVerifier.provePossession(
            proofSetId,
            proofs,
            { value: proofFee }
        );
        
        // Wait for the transaction to be mined
        const receipt = await tx.wait();
        
        console.log(`Proofs submitted in transaction: ${receipt.transactionHash}`);
        
        // Verify proof submission
        const lastProvenEpoch = await pdpVerifier.getProofSetLastProvenEpoch(proofSetId);
        console.log(`Last proven epoch: ${lastProvenEpoch}`);
        
        // Check if the next challenge epoch has been updated
        const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
        console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
    });
}

// Usage
submitProofs(your_proof_set_id)
    .catch(error => console.error(`Error submitting proofs: ${error}`));
```

## Automating Proof Submission

In a production environment, you'll want to automate proof submission. Here's a simple Node.js script that you can run as a cron job:

```javascript
const fs = require('fs');
const ethers = require('ethers');
const { exec } = require('child_process');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

// Configuration
const config = {
    rpcUrl: 'https://calibration.filfox.info/rpc/v1',
    privateKey: 'your_private_key',
    pdpVerifierAddress: '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC',
    proofSetIds: [1, 2, 3], // List of proof set IDs to monitor
    checkIntervalMinutes: 10, // How often to check if proofs need to be submitted
};

// Connect to the provider
const provider = new ethers.providers.JsonRpcProvider(config.rpcUrl);
const wallet = new ethers.Wallet(config.privateKey, provider);
const pdpVerifier = new ethers.Contract(config.pdpVerifierAddress, pdpVerifierAbi, wallet);

// Main function to check and submit proofs
async function checkAndSubmitProofs() {
    const currentEpoch = await provider.getBlockNumber();
    console.log(`Current epoch: ${currentEpoch}`);
    
    for (const proofSetId of config.proofSetIds) {
        try {
            // Check if the proof set is live
            const isLive = await pdpVerifier.proofSetLive(proofSetId);
            if (!isLive) {
                console.log(`Proof set ${proofSetId} is not live. Skipping.`);
                continue;
            }
            
            // Check the next challenge epoch
            const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
            console.log(`Proof set ${proofSetId} - Next challenge epoch: ${nextChallengeEpoch}`);
            
            // If it's time to submit proofs
            if (currentEpoch >= nextChallengeEpoch) {
                console.log(`Submitting proofs for proof set ${proofSetId}...`);
                submitProofs(proofSetId);
            } else {
                console.log(`Proof set ${proofSetId} - Wait ${nextChallengeEpoch - currentEpoch} more epochs.`);
            }
        } catch (error) {
            console.error(`Error processing proof set ${proofSetId}: ${error}`);
        }
    }
}

// Function to submit proofs
async function submitProofs(proofSetId) {
    // Generate proofs using the PDP Tool
    const command = `pdp prove --proof-set-id ${proofSetId} --verifier-address ${config.pdpVerifierAddress} --rpc-url ${config.rpcUrl}`;
    
    exec(command, async (error, stdout, stderr) => {
        if (error) {
            console.error(`Error generating proofs for proof set ${proofSetId}: ${error}`);
            return;
        }
        
        try {
            // Load the proofs from the JSON file
            const proofsJson = fs.readFileSync(`./proofs_${proofSetId}.json`, 'utf8');
            const proofs = JSON.parse(proofsJson);
            
            // Calculate the proof fee
            const estimatedGasFee = 1000000; // Estimate gas fee (adjust as needed)
            const proofFee = await pdpVerifier.calculateProofFee(proofSetId, estimatedGasFee);
            
            console.log(`Proof set ${proofSetId} - Proof fee: ${ethers.utils.formatEther(proofFee)} ETH`);
            
            // Submit the proofs
            const tx = await pdpVerifier.provePossession(
                proofSetId,
                proofs,
                { value: proofFee }
            );
            
            // Wait for the transaction to be mined
            const receipt = await tx.wait();
            
            console.log(`Proof set ${proofSetId} - Proofs submitted in transaction: ${receipt.transactionHash}`);
        } catch (error) {
            console.error(`Error submitting proofs for proof set ${proofSetId}: ${error}`);
        }
    });
}

// Run the check immediately
checkAndSubmitProofs();

// Then run it periodically
setInterval(checkAndSubmitProofs, config.checkIntervalMinutes * 60 * 1000);
```

## Next Steps

After submitting proofs, you may want to:

1. [Verify the proofs](verifying-proofs.md) to ensure they were accepted
2. [Handle any faults](handling-faults.md) that may have occurred
3. [Settle payments](../../payments/guides/first-rail.md#step-6-settle-payments) if you're using the Payments system

For a complete example of submitting proofs in a real application, see the [Hot Vault Demo](../../examples/hot-vault.md).
