# Step 2: Quick SDK Setup

This is the second step in your Developer Path to success with PDP-Payments. You'll install and initialize the Synapse SDK for rapid development.

## Prerequisites

- ✅ **Completed [Step 1: Setup Wallet & USDFC](setup.md)** - You have MetaMask with testnet tokens
- ✅ **Node.js** (v16 or later) installed
- ✅ **Basic JavaScript/TypeScript** knowledge

## 1. Create Your Project

Start with a fresh project directory:

```bash
mkdir my-pdp-app
cd my-pdp-app
npm init -y
```

## 2. Install Synapse SDK

```bash
npm install synapse-sdk
```

**What you get:**
- 🎯 **Simple API**: Store files in ~5 lines of code
- 💰 **Integrated Payments**: Automatic USDFC handling
- 🔍 **PDP Verification**: Built-in storage proofs
- 📦 **TypeScript Support**: Full type safety

## 3. Environment Setup

Create a `.env` file with your private key:

```bash
# .env
PRIVATE_KEY=your_private_key_here_without_0x_prefix
```

**🔐 Get Your Private Key:**
1. Open MetaMask → Account Details → Export Private Key
2. Enter password → Copy key (remove `0x` prefix)
3. **Never commit `.env` to version control!**

## 4. Your First SDK Script

Create `test-sdk.js`:

```javascript
// test-sdk.js
import { Synapse } from 'synapse-sdk'
import 'dotenv/config'

async function testSDK() {
  console.log('🚀 Testing Synapse SDK...')
  
  // Initialize SDK
  const synapse = new Synapse({
    privateKey: process.env.PRIVATE_KEY,
    withCDN: true, // Enable faster retrievals
    // SDK automatically uses Calibration testnet
  })
  
  // Check balance
  console.log('💰 Checking balance...')
  const balance = await synapse.balance()
  console.log(`Current balance: ${balance} USDFC`)
  
  // Create storage service
  console.log('📦 Creating storage service...')
  const storage = await synapse.createStorage()
  console.log(`Storage service ready!`)
  console.log(`- Proof Set ID: ${storage.proofSetId}`)
  console.log(`- Storage Provider: ${storage.storageProvider}`)
  
  console.log('✅ SDK setup successful!')
}

testSDK().catch(console.error)
```

## 5. Test Your Setup

```bash
node test-sdk.js
```

**Expected Output:**
```
🚀 Testing Synapse SDK...
💰 Checking balance...
[Mock] Checking balance...
Current balance: 100 USDFC
📦 Creating storage service...
[Mock] Creating storage service...
[Mock] Storage service created with proofSetId: ps_abc123, SP: f01234
Storage service ready!
- Proof Set ID: ps_abc123
- Storage Provider: f01234
✅ SDK setup successful!
```

> **📝 Note**: You're seeing `[Mock]` messages because the SDK is currently in mock mode for development. The API patterns are real and will work with the production implementation.

## 6. SDK vs Raw Contracts

**With Synapse SDK (What you just did):**
```javascript
// 5 lines to get started
const synapse = new Synapse({ privateKey })
const balance = await synapse.balance()
const storage = await synapse.createStorage()
```

**Without SDK (Raw contracts):**
```javascript
// 50+ lines for the same functionality
const provider = new ethers.JsonRpcProvider(rpcUrl)
const wallet = new ethers.Wallet(privateKey, provider)
const pdpContract = new ethers.Contract(pdpAddress, pdpAbi, wallet)
const paymentsContract = new ethers.Contract(paymentsAddress, paymentsAbi, wallet)
// ... 40+ more lines of setup and coordination
```

**💡 The SDK abstracts away:**
- ❌ Contract address management
- ❌ ABI handling
- ❌ Network configuration
- ❌ Payment coordination complexity
- ❌ Error handling boilerplate

## 7. What's Next?

You're ready for **[Step 3: Complete Workflow](sdk-workflow.md)** where you'll:
- 💰 Manage USDFC deposits and withdrawals
- 📁 Store your first file with automatic payment escrow
- 🔍 Monitor storage proofs
- 💸 Settle payments with storage providers
- 📥 Retrieve your stored files

## Troubleshooting

### SDK Import Issues
```bash
# If you get import errors, try:
npm install --save-dev @types/node

# Or use CommonJS:
const { Synapse } = require('synapse-sdk')
```

### Private Key Issues
- ✅ Remove `0x` prefix from private key
- ✅ Ensure `.env` file is in project root
- ✅ Check `.env` is not committed to git

### Balance Shows 0
- The mock SDK starts with 100 USDFC balance
- If you see 0, check your private key setup
- Real implementation will check actual on-chain balance

## Next Steps

Continue to **[Step 3: Complete Workflow](sdk-workflow.md)** to see the full power of integrated PDP + Payments! 🚀
