# Verifying Proofs

This guide explains how to verify proofs in the PDP system, which is essential for confirming that storage providers are maintaining your data correctly.

## Prerequisites

- An Ethereum wallet with some ETH for gas
- A proof set ID from [creating a proof set](creating-proof-set.md)
- Proofs that have been [submitted](submitting-proofs.md) by the storage provider

## Step 1: Connect to the PDPVerifier Contract

First, connect to the PDPVerifier contract:

```javascript
const ethers = require('ethers');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');

// Connect to the provider
const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');

// Connect to the PDPVerifier contract
const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC'; // Calibration testnet
const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, provider);
```

## Step 2: Check Proof Status

You can check the status of proofs for a specific proof set:

```javascript
async function checkProofStatus(proofSetId) {
    // Check if the proof set is live
    const isLive = await pdpVerifier.proofSetLive(proofSetId);
    console.log(`Proof set ${proofSetId} is live: ${isLive}`);
    
    if (!isLive) {
        console.log('Proof set is not live. No proofs can be verified.');
        return;
    }
    
    // Get the last proven epoch
    const lastProvenEpoch = await pdpVerifier.getProofSetLastProvenEpoch(proofSetId);
    console.log(`Last proven epoch: ${lastProvenEpoch}`);
    
    // Get the next challenge epoch
    const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
    console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
    
    // Get the current epoch
    const currentEpoch = await provider.getBlockNumber();
    console.log(`Current epoch: ${currentEpoch}`);
    
    // Check if proofs are up to date
    if (lastProvenEpoch >= nextChallengeEpoch - 1) {
        console.log('Proofs are up to date.');
    } else {
        console.log('Proofs are not up to date. The storage provider needs to submit new proofs.');
    }
}
```

## Step 3: Check Fault Count

You can check if there have been any faults (missed or invalid proofs):

```javascript
async function checkFaultCount(proofSetId) {
    // Get the PDP service address for this proof set
    const pdpServiceAddress = await pdpVerifier.getProofSetService(proofSetId);
    console.log(`PDP service address: ${pdpServiceAddress}`);
    
    // Connect to the PDP service contract
    const pdpServiceAbi = require('./abis/SimplePDPService.json');
    const pdpService = new ethers.Contract(pdpServiceAddress, pdpServiceAbi, provider);
    
    // Get the fault count
    const faultCount = await pdpService.getFaultCount(proofSetId);
    console.log(`Fault count: ${faultCount}`);
    
    if (faultCount.toNumber() > 0) {
        console.log('There have been faults in proof submission. This may affect payments.');
    } else {
        console.log('No faults detected. All proofs have been submitted correctly.');
    }
}
```

## Step 4: Verify Proof Details

For more detailed verification, you can check the specific proof details:

```javascript
async function getProofDetails(proofSetId) {
    // Get the proof set details
    const proofSet = await pdpVerifier.getProofSet(proofSetId);
    console.log('Proof set details:');
    console.log(`- Service: ${proofSet.service}`);
    console.log(`- Owner: ${proofSet.owner}`);
    console.log(`- Data root count: ${proofSet.dataRootCount}`);
    console.log(`- Last proven epoch: ${proofSet.lastProvenEpoch}`);
    
    // Get the PDP service address for this proof set
    const pdpServiceAddress = await pdpVerifier.getProofSetService(proofSetId);
    
    // Connect to the PDP service contract
    const pdpServiceAbi = require('./abis/SimplePDPService.json');
    const pdpService = new ethers.Contract(pdpServiceAddress, pdpServiceAbi, provider);
    
    // Get the service parameters
    const maxProvingPeriod = await pdpService.maxProvingPeriod();
    const challengeWindow = await pdpService.challengeWindow();
    const challengesPerProof = await pdpService.challengesPerProof();
    
    console.log('Service parameters:');
    console.log(`- Maximum proving period: ${maxProvingPeriod} epochs`);
    console.log(`- Challenge window: ${challengeWindow} epochs`);
    console.log(`- Challenges per proof: ${challengesPerProof}`);
    
    // Calculate the next deadline
    const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
    const deadlineEpoch = nextChallengeEpoch + challengeWindow;
    const currentEpoch = await provider.getBlockNumber();
    
    console.log('Proof timing:');
    console.log(`- Current epoch: ${currentEpoch}`);
    console.log(`- Next challenge epoch: ${nextChallengeEpoch}`);
    console.log(`- Deadline epoch: ${deadlineEpoch}`);
    console.log(`- Time until deadline: ${deadlineEpoch - currentEpoch} epochs`);
}
```

## Step 5: Verify Proof Submission Events

You can also check for proof submission events:

```javascript
async function getProofSubmissionEvents(proofSetId) {
    // Define the event filter
    const filter = pdpVerifier.filters.ProofSubmitted(proofSetId);
    
    // Get the events (last 1000 blocks)
    const currentBlock = await provider.getBlockNumber();
    const events = await pdpVerifier.queryFilter(filter, currentBlock - 1000, currentBlock);
    
    console.log(`Found ${events.length} proof submission events for proof set ${proofSetId}:`);
    
    for (const event of events) {
        console.log(`- Block: ${event.blockNumber}`);
        console.log(`  Transaction: ${event.transactionHash}`);
        console.log(`  Submitter: ${event.args.submitter}`);
        console.log(`  Epoch: ${event.args.epoch}`);
    }
}
```

## Complete Example

Here's a complete example of verifying proofs for a proof set:

```javascript
const ethers = require('ethers');
const pdpVerifierAbi = require('./abis/PDPVerifier.json');
const pdpServiceAbi = require('./abis/SimplePDPService.json');

async function verifyProofs(proofSetId) {
    try {
        // Connect to the provider
        const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
        
        // Connect to the PDPVerifier contract
        const pdpVerifierAddress = '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC'; // Calibration testnet
        const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, provider);
        
        // Check if the proof set is live
        const isLive = await pdpVerifier.proofSetLive(proofSetId);
        console.log(`Proof set ${proofSetId} is live: ${isLive}`);
        
        if (!isLive) {
            console.log('Proof set is not live. No proofs can be verified.');
            return;
        }
        
        // Get the proof set details
        const proofSet = await pdpVerifier.getProofSet(proofSetId);
        console.log('Proof set details:');
        console.log(`- Service: ${proofSet.service}`);
        console.log(`- Owner: ${proofSet.owner}`);
        console.log(`- Data root count: ${proofSet.dataRootCount}`);
        console.log(`- Last proven epoch: ${proofSet.lastProvenEpoch}`);
        
        // Get the PDP service address for this proof set
        const pdpServiceAddress = await pdpVerifier.getProofSetService(proofSetId);
        
        // Connect to the PDP service contract
        const pdpService = new ethers.Contract(pdpServiceAddress, pdpServiceAbi, provider);
        
        // Get the service parameters
        const maxProvingPeriod = await pdpService.maxProvingPeriod();
        const challengeWindow = await pdpService.challengeWindow();
        const challengesPerProof = await pdpService.challengesPerProof();
        
        console.log('Service parameters:');
        console.log(`- Maximum proving period: ${maxProvingPeriod} epochs`);
        console.log(`- Challenge window: ${challengeWindow} epochs`);
        console.log(`- Challenges per proof: ${challengesPerProof}`);
        
        // Get the fault count
        const faultCount = await pdpService.getFaultCount(proofSetId);
        console.log(`Fault count: ${faultCount}`);
        
        // Get the next challenge epoch
        const nextChallengeEpoch = await pdpVerifier.getNextChallengeEpoch(proofSetId);
        console.log(`Next challenge epoch: ${nextChallengeEpoch}`);
        
        // Get the current epoch
        const currentEpoch = await provider.getBlockNumber();
        console.log(`Current epoch: ${currentEpoch}`);
        
        // Check if proofs are up to date
        if (proofSet.lastProvenEpoch >= nextChallengeEpoch - maxProvingPeriod) {
            console.log('Proofs are up to date.');
        } else {
            console.log('Proofs are not up to date. The storage provider needs to submit new proofs.');
        }
        
        // Get proof submission events
        const filter = pdpVerifier.filters.ProofSubmitted(proofSetId);
        const events = await pdpVerifier.queryFilter(filter, currentEpoch - 1000, currentEpoch);
        
        console.log(`Found ${events.length} recent proof submission events.`);
        
        if (events.length > 0) {
            console.log('Most recent proof submission:');
            const latestEvent = events[events.length - 1];
            console.log(`- Block: ${latestEvent.blockNumber}`);
            console.log(`- Transaction: ${latestEvent.transactionHash}`);
            console.log(`- Submitter: ${latestEvent.args.submitter}`);
            console.log(`- Epoch: ${latestEvent.args.epoch}`);
        }
    } catch (error) {
        console.error(`Error verifying proofs: ${error}`);
    }
}

// Usage
verifyProofs(your_proof_set_id)
    .catch(error => console.error(`Error: ${error}`));
```

## Next Steps

After verifying proofs, you may want to:

1. [Handle any faults](handling-faults.md) that may have occurred
2. [Settle payments](../../payments/guides/first-rail.md#step-6-settle-payments) if you're using the Payments system
3. [Monitor proof submissions](monitoring-proofs.md) over time

For a complete example of verifying proofs in a real application, see the [Hot Vault Demo](../../examples/hot-vault.md).
