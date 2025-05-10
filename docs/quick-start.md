# Quick Start Guide

This guide will help you get started with the FilOz ecosystem, including both the Provable Data Possession (PDP) and Payments systems.

## Prerequisites

Before you begin, ensure you have:

- [Node.js](https://nodejs.org/) (v16 or later)
- [npm](https://www.npmjs.com/) (v7 or later)
- [MetaMask](https://metamask.io/) or another Ethereum wallet
- Basic knowledge of Ethereum and smart contracts
- Some test tokens on Filecoin Calibration Testnet

## Step 1: Connect to Filecoin Calibration Testnet

1. Open MetaMask and add the Filecoin Calibration Testnet:
   - Network Name: `Filecoin Calibration Testnet`
   - RPC URL: `https://calibration.filfox.info/rpc/v1`
   - Chain ID: `314159`
   - Currency Symbol: `tFIL`
   - Block Explorer URL: `https://calibration.filfox.info/`

2. Get some test tokens:
   - Visit the [Filecoin Faucet](https://faucet.calibration.fildev.network/)
   - Enter your wallet address
   - Receive test tFIL

## Step 2: Set Up Your Development Environment

Create a new project and install the required dependencies:

```bash
# Create a new directory
mkdir filoz-quickstart
cd filoz-quickstart

# Initialize a new npm project
npm init -y

# Install dependencies
npm install ethers@5.7.2 dotenv
```

Create a `.env` file to store your private keys and contract addresses:

```
# .env
PRIVATE_KEY=your_private_key_here
PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A
```

## Step 3: Create a Basic Script

Create a file named `index.js` with the following content:

```javascript
require('dotenv').config();
const ethers = require('ethers');

// Contract ABIs
const pdpVerifierAbi = require('./abis/PDPVerifier.json');
const pdpServiceAbi = require('./abis/SimplePDPService.json');
const paymentsAbi = require('./abis/Payments.json');

// Environment variables
const privateKey = process.env.PRIVATE_KEY;
const pdpVerifierAddress = process.env.PDP_VERIFIER_ADDRESS;
const pdpServiceAddress = process.env.PDP_SERVICE_ADDRESS;
const paymentsAddress = process.env.PAYMENTS_ADDRESS;

// Provider and signer
const provider = new ethers.providers.JsonRpcProvider('https://calibration.filfox.info/rpc/v1');
const wallet = new ethers.Wallet(privateKey, provider);

// Contract instances
const pdpVerifier = new ethers.Contract(pdpVerifierAddress, pdpVerifierAbi, wallet);
const pdpService = new ethers.Contract(pdpServiceAddress, pdpServiceAbi, wallet);
const payments = new ethers.Contract(paymentsAddress, paymentsAbi, wallet);

async function main() {
  console.log('Connected to Filecoin Calibration Testnet');
  
  // Get the current block number
  const blockNumber = await provider.getBlockNumber();
  console.log(`Current block number: ${blockNumber}`);
  
  // Get the next proof set ID
  const nextProofSetId = await pdpVerifier.getNextProofSetId();
  console.log(`Next proof set ID: ${nextProofSetId}`);
  
  // Get the maximum proving period
  const maxProvingPeriod = await pdpService.getMaxProvingPeriod();
  console.log(`Maximum proving period: ${maxProvingPeriod} epochs`);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

Create a directory for ABIs and download the necessary ABI files:

```bash
mkdir abis
# Download ABIs from the FilOz repositories
# You can find these in the artifacts directories of the respective repositories
```

## Step 4: Run Your First Script

Run the script to verify your connection:

```bash
node index.js
```

You should see output similar to:

```
Connected to Filecoin Calibration Testnet
Current block number: 1234567
Next proof set ID: 42
Maximum proving period: 60 epochs
```

## Step 5: Create a Payment Rail

Let's create a payment rail between two addresses:

```javascript
async function createPaymentRail() {
  const tokenAddress = '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0'; // USDFC on Calibration
  const fromAddress = wallet.address; // Your address
  const toAddress = '0x...'; // Recipient address
  const arbiterAddress = ethers.constants.AddressZero; // No arbiter for now
  const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDFC per epoch
  const lockupPeriod = 60; // 60 epochs
  const lockupFixed = ethers.utils.parseUnits('1', 6); // 1 USDFC fixed lockup
  const commissionRate = 0; // No commission
  
  console.log('Creating payment rail...');
  
  // First, approve the Payments contract to spend your tokens
  const tokenAbi = ['function approve(address spender, uint256 amount) returns (bool)'];
  const token = new ethers.Contract(tokenAddress, tokenAbi, wallet);
  
  const approvalAmount = ethers.utils.parseUnits('100', 6); // 100 USDFC
  const approveTx = await token.approve(paymentsAddress, approvalAmount);
  await approveTx.wait();
  console.log('Token approval confirmed');
  
  // Deposit funds into the Payments contract
  const depositAmount = ethers.utils.parseUnits('10', 6); // 10 USDFC
  const depositTx = await payments.deposit(tokenAddress, wallet.address, depositAmount);
  await depositTx.wait();
  console.log('Deposit confirmed');
  
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
}
```

## Step 6: Create a Proof Set

Now, let's create a proof set in the PDP system:

```javascript
async function createProofSet(railId) {
  // Encode the payment rail ID in the extra data
  const extraData = ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address'],
    [railId, paymentsAddress]
  );
  
  console.log('Creating proof set...');
  
  // Calculate the sybil fee
  const sybilFee = await pdpVerifier.sybilFee();
  console.log(`Sybil fee: ${ethers.utils.formatEther(sybilFee)} tFIL`);
  
  // Create the proof set
  const tx = await pdpVerifier.createProofSet(
    pdpServiceAddress,
    extraData,
    { value: sybilFee }
  );
  
  const receipt = await tx.wait();
  const proofSetId = receipt.events[0].args.setId;
  console.log(`Created proof set with ID: ${proofSetId}`);
  
  return proofSetId;
}
```

## Step 7: Add Data to the Proof Set

To add data to the proof set, you'll need to prepare a CID and its size:

```javascript
async function addDataToProofSet(proofSetId) {
  // This is a simplified example - in a real application, you would:
  // 1. Create a CAR file from your data
  // 2. Calculate the CID
  // 3. Determine the size
  
  // For this example, we'll use a dummy CID
  const cidVersion = 1;
  const cidCodec = 0x71; // dag-cbor
  const cidHash = 0x12; // sha2-256
  const cidSize = 32;
  const cidData = ethers.utils.randomBytes(32); // Random bytes for demo
  
  const rootCid = {
    version: cidVersion,
    codec: cidCodec,
    hash: cidHash,
    size: cidSize,
    data: cidData
  };
  
  const dataSize = 1024 * 1024; // 1 MB for demo
  
  const rootData = [{
    root: rootCid,
    rawSize: dataSize
  }];
  
  console.log('Adding data to proof set...');
  
  // Add the root to the proof set
  const tx = await pdpVerifier.addRoots(
    proofSetId,
    rootData,
    '0x' // No extra data
  );
  
  await tx.wait();
  console.log('Data added to proof set');
}
```

## Step 8: Update Your Main Function

Update your `main` function to use these new functions:

```javascript
async function main() {
  console.log('Connected to Filecoin Calibration Testnet');
  
  // Create a payment rail
  const railId = await createPaymentRail();
  
  // Create a proof set
  const proofSetId = await createProofSet(railId);
  
  // Add data to the proof set
  await addDataToProofSet(proofSetId);
  
  console.log('Quick start complete!');
  console.log(`Payment Rail ID: ${railId}`);
  console.log(`Proof Set ID: ${proofSetId}`);
}
```

## Next Steps

Now that you've created a basic integration with FilOz, you can:

1. **Implement Proof Submission**: Learn how to [submit proofs](pdp/guides/submitting-proofs.md) to demonstrate data possession
2. **Settle Payments**: Explore how to [settle payments](payments/guides/first-rail.md#step-6-settle-payments) on your payment rail
3. **Implement an Arbiter**: Create a custom [arbiter contract](payments/guides/custom-arbiter.md) to adjust payments based on proof compliance
4. **Explore the Hot Vault Demo**: See a complete implementation in the [Hot Vault Demo](examples/hot-vault.md)

## Additional Resources

- [PDP Overview](pdp/concepts/overview.md)
- [Payments Overview](payments/concepts/overview.md)
- [Integrating PDP with Payments](integration/pdp-payments.md)
- [API References](index.md#payments-api-reference)
