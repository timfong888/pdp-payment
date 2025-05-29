# Setting Up Your Environment for PDP-Payments (FWS)

This guide will walk you through setting up your development environment for working with the PDP-Payments (FWS) system, including both the Provable Data Possession (PDP) and Payments components.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v16 or later)
- [npm](https://www.npmjs.com/) (v7 or later)
- [Git](https://git-scm.com/)
- [MetaMask](https://metamask.io/) or another Ethereum wallet
- Basic knowledge of Ethereum and smart contracts

## Step 1: Set Up Your Blockchain Environment

### Connect to Filecoin Calibration Testnet

For development and testing, we recommend using the Filecoin Calibration Testnet:

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

### Get Test USDC Tokens

For payment functionality, you'll need test USDC tokens:

1. Visit a testnet USDC faucet (specific to Filecoin Calibration)
2. Request test USDC tokens to your wallet address
3. Verify the tokens appear in your wallet

## Step 2: Clone the Repository

Clone the PDP-Payments (FWS) repository to your local machine:

```bash
git clone https://github.com/timfong888/pdp-payment.git
cd pdp-payment
```

## Step 3: Install Dependencies

Install the required dependencies:

```bash
npm install
```

This will install all the necessary packages, including:
- ethers.js for blockchain interactions
- dotenv for environment variable management
- Other dependencies required by the project

## Step 4: Configure Environment Variables

Create a `.env` file in the root directory of the project:

```bash
touch .env
```

Add the following environment variables to the `.env` file:

```
# Private key (without 0x prefix)
PRIVATE_KEY=your_private_key_here

# Contract addresses
PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A

# RPC URL
RPC_URL=https://calibration.filfox.info/rpc/v1

# Token address (USDC on Calibration)
TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0
```

**Important**: Never commit your `.env` file to version control. Make sure it's included in your `.gitignore` file.

## Step 5: Set Up Contract ABIs

Create a directory for ABIs and download the necessary ABI files:

```bash
mkdir -p abis
```

You'll need the following ABI files:
- PDPVerifier.json
- SimplePDPService.json
- Payments.json

These can be obtained from the contract repositories or compiled from the contract source code.

## Step 6: Verify Your Setup

Create a simple script to verify your setup:

```javascript
// verify-setup.js
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
const rpcUrl = process.env.RPC_URL;

// Provider and signer
const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
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
  
  // Get wallet balance
  const balance = await provider.getBalance(wallet.address);
  console.log(`Wallet balance: ${ethers.utils.formatEther(balance)} tFIL`);
  
  console.log('Setup verification complete!');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

Run the verification script:

```bash
node verify-setup.js
```

If everything is set up correctly, you should see output similar to:

```
Connected to Filecoin Calibration Testnet
Current block number: 1234567
Next proof set ID: 42
Maximum proving period: 60 epochs
Wallet balance: 1.5 tFIL
Setup verification complete!
```

## Step 7: Set Up Development Tools

For a better development experience, we recommend setting up the following tools:

### Hardhat (for contract development and testing)

```bash
npm install --save-dev hardhat
npx hardhat init
```

### Solidity Extension for VS Code

If you're using Visual Studio Code, install the Solidity extension:
- Open VS Code
- Go to Extensions (Ctrl+Shift+X)
- Search for "Solidity" and install the extension by Juan Blanco

## Step 8: Explore the Documentation

Now that your environment is set up, explore the rest of the documentation to learn how to use the PDP-Payments (FWS) system:

- [PDP Overview](pdp-overview.md): Understand the Provable Data Possession system
- [Payments Overview](payments-overview.md): Learn about the Payments system
- [Integration Guide](integration-guide.md): See how to integrate PDP with Payments
- [Quick Start](quick-start.md): Follow a quick start guide to build your first application
- [Hot Vault Example](examples/hot-vault.md): Explore a complete example implementation

## Troubleshooting

### Connection Issues

If you're having trouble connecting to the Filecoin Calibration Testnet:
- Verify your RPC URL is correct
- Check if the network is experiencing any issues
- Try using a different RPC endpoint

### Contract Interaction Errors

If you encounter errors when interacting with contracts:
- Ensure you have the correct contract addresses
- Verify your ABI files match the deployed contracts
- Check if you have sufficient tFIL for gas fees

### Token Issues

If you're having trouble with tokens:
- Verify you have the correct token address
- Ensure you have sufficient token balance
- Check if you've approved the Payments contract to spend your tokens

## Next Steps

After setting up your environment, proceed to the [Quick Start Guide](quick-start.md) to begin building with the PDP-Payments (FWS) system.
