# Setting Up Your Environment

This guide will help you set up your environment to work with the FilOz ecosystem.

## Prerequisites

Before you begin, ensure you have:

- [Node.js](https://nodejs.org/) (v16 or later)
- [npm](https://www.npmjs.com/) (v7 or later)
- [MetaMask](https://metamask.io/) or another Ethereum wallet
- Basic knowledge of Ethereum and smart contracts

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
mkdir filoz-project
cd filoz-project

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

## Step 3: Set Up Contract ABIs

Create a directory for ABIs and download the necessary ABI files:

```bash
mkdir abis
```

### PDPVerifier ABI

Create a file `abis/PDPVerifier.json` with the PDPVerifier contract ABI. You can find this in the [pdp repository](https://github.com/FilOzone/pdp).

### SimplePDPService ABI

Create a file `abis/SimplePDPService.json` with the SimplePDPService contract ABI. You can find this in the [pdp repository](https://github.com/FilOzone/pdp).

### Payments ABI

Create a file `abis/Payments.json` with the Payments contract ABI. You can find this in the [payments repository](https://github.com/FilOzone/payments).

## Step 4: Create a Basic Script

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

## Step 5: Run Your First Script

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

## Next Steps

Now that you have set up your environment, you can:

1. Learn about [Creating Your First Storage Deal](first-deal.md)
2. Explore the [PDP System](pdp-overview.md)
3. Understand the [Payments System](payments.md)

For a complete example of using FilOz in a real application, see the [Hot Vault Demo](examples/hot-vault.md).
