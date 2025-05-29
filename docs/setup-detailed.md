# Step 2: Configure JSON-RPC for Filecoin

This is the second step in your Golden Path. You'll set up Filecoin JSON-RPC connections to interact with the blockchain and prepare your development environment.

## Prerequisites

- ✅ Completed [Step 1: Setup Wallet & USDFC](setup.md)
- **Node.js** (v18 or later) installed
- **npm** (v9 or later) installed
- **Git** installed
- **Code editor** (VS Code recommended)

## 1. Understanding Filecoin JSON-RPC

Filecoin provides JSON-RPC APIs for interacting with the blockchain. There are two main types:

### Filecoin JSON-RPC API
- **Purpose**: Native Filecoin operations (storage deals, mining, etc.)
- **Endpoint**: `https://api.calibration.node.glif.io/rpc/v1`
- **Use cases**: Storage provider interactions, deal making

### Ethereum-compatible JSON-RPC API
- **Purpose**: Smart contract interactions (what we'll use for PDP-Payments)
- **Endpoint**: `https://api.calibration.node.glif.io/rpc/v1` (same endpoint, different methods)
- **Use cases**: Contract deployment, token transfers, PDP operations

## 2. Available RPC Endpoints

### Recommended Endpoints for Calibration Testnet

**Glif (Recommended)**
- HTTPS: `https://api.calibration.node.glif.io/rpc/v1`
- WebSocket: `wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v1`
- **Note**: Guarantees 2000 latest blocks

**Ankr**
- HTTPS: `https://rpc.ankr.com/filecoin_testnet`

**ChainupCloud**
- HTTPS: `https://filecoin-calibration.chainup.net/rpc/v1`

## 3. Set Up Your Development Environment

### Clone the Documentation Repository

```bash
git clone https://github.com/timfong888/pdp-payment.git
cd pdp-payment
```

### Install Node.js Dependencies

```bash
npm install
```

This installs essential packages:
- **ethers.js**: Ethereum/Filecoin blockchain interactions
- **dotenv**: Environment variable management
- **web3**: Alternative blockchain library

## 4. Configure Environment Variables

### Create Environment File

```bash
touch .env
```

### Add Configuration

Add the following to your `.env` file:

```bash
# Wallet Configuration
PRIVATE_KEY=your_private_key_here_without_0x_prefix

# Filecoin Calibration Testnet RPC
RPC_URL=https://api.calibration.node.glif.io/rpc/v1

# Contract Addresses (Calibration Testnet)
PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A

# Token Addresses
USDFC_TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

# Network Configuration
CHAIN_ID=314159
NETWORK_NAME=calibration
```

### Get Your Private Key

1. Open MetaMask
2. Click the three dots menu → Account details
3. Click "Export Private Key"
4. Enter your password
5. Copy the private key (remove the `0x` prefix)
6. Paste into your `.env` file

**⚠️ Security Warning**: Never commit your `.env` file to version control!

## 5. Test Your JSON-RPC Connection

### Create a Connection Test Script

Create `test-connection.js`:

```javascript
// test-connection.js
require('dotenv').config();
const { ethers } = require('ethers');

async function testConnection() {
  try {
    // Create provider
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);

    // Test basic connection
    console.log('🔗 Testing Filecoin JSON-RPC connection...');
    const network = await provider.getNetwork();
    console.log(`✅ Connected to network: ${network.name} (Chain ID: ${network.chainId})`);

    // Get current block
    const blockNumber = await provider.getBlockNumber();
    console.log(`📦 Current block number: ${blockNumber}`);

    // Test wallet connection
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    console.log(`👛 Wallet address: ${wallet.address}`);

    // Check balances
    const filBalance = await provider.getBalance(wallet.address);
    console.log(`💰 tFIL balance: ${ethers.formatEther(filBalance)} tFIL`);

    // Test USDFC token balance
    const usdcAbi = [
      "function balanceOf(address owner) view returns (uint256)",
      "function symbol() view returns (string)",
      "function decimals() view returns (uint8)"
    ];

    const usdcContract = new ethers.Contract(
      process.env.USDFC_TOKEN_ADDRESS,
      usdcAbi,
      provider
    );

    const usdcBalance = await usdcContract.balanceOf(wallet.address);
    const usdcDecimals = await usdcContract.decimals();
    const usdcSymbol = await usdcContract.symbol();

    console.log(`💵 ${usdcSymbol} balance: ${ethers.formatUnits(usdcBalance, usdcDecimals)} ${usdcSymbol}`);

    console.log('\n🎉 JSON-RPC connection test successful!');

  } catch (error) {
    console.error('❌ Connection test failed:', error.message);
    process.exit(1);
  }
}

testConnection();
```

### Run the Test

```bash
node test-connection.js
```

**Expected Output:**
```
🔗 Testing Filecoin JSON-RPC connection...
✅ Connected to network: filecoin-calibration (Chain ID: 314159)
📦 Current block number: 1234567
👛 Wallet address: 0x1234...abcd
💰 tFIL balance: 50.0 tFIL
💵 USDFC balance: 30.0 USDFC

🎉 JSON-RPC connection test successful!
```

## 6. Understanding JSON-RPC Methods

### Common Ethereum-Compatible Methods

These methods work with Filecoin's EVM-compatible layer:

```javascript
// Get latest block number
await provider.getBlockNumber()

// Get account balance
await provider.getBalance(address)

// Get transaction receipt
await provider.getTransactionReceipt(txHash)

// Send transaction
await wallet.sendTransaction({
  to: "0x...",
  value: ethers.parseEther("1.0")
})

// Call contract method
await contract.methodName(params)
```

### Filecoin-Specific Methods

For native Filecoin operations (advanced usage):

```javascript
// Get chain head
await provider.send("Filecoin.ChainHead", [])

// Get actor state
await provider.send("Filecoin.StateGetActor", [address, null])
```

## Troubleshooting

### Connection Issues
- **RPC timeout**: Try a different endpoint (Ankr or ChainupCloud)
- **Network mismatch**: Ensure Chain ID is 314159
- **Rate limiting**: Use your own RPC node for heavy usage

### Authentication Errors
- **Invalid private key**: Ensure no `0x` prefix in `.env`
- **Wrong network**: Verify you're on Calibration testnet
- **Insufficient gas**: Ensure you have tFIL for transactions

### Contract Interaction Issues
- **Contract not found**: Verify contract addresses are correct
- **Method not found**: Check ABI matches deployed contract
- **Transaction reverted**: Check contract state and parameters

## Next Steps

🎉 **Congratulations!** You've completed Step 2 of the Golden Path.

**Next**: [Step 3: Install Synapse SDK](quick-start.md) - Create a local app using the Synapse SDK

## Additional Resources

- [Filecoin JSON-RPC Documentation](https://docs.filecoin.io/reference/json-rpc/)
- [Ethers.js Documentation](https://docs.ethers.org/)
- [Filecoin EVM Documentation](https://docs.filecoin.io/smart-contracts/fundamentals/)
