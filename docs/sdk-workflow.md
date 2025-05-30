# Step 3: Complete Storage + Payment Workflow

This is the third step in your Developer Path - the **core value demonstration** of PDP-Payments. You'll see how the Synapse SDK integrates storage and payments into a seamless workflow.

## Prerequisites

- ✅ **Completed [Step 2: Quick SDK Setup](sdk-quickstart.md)** - SDK is installed and tested
- ✅ **USDFC tokens** from [Step 1](setup.md) for real payments

## 🎯 What You'll Learn

The **killer feature** of PDP-Payments: **automatic payment coordination** with storage operations.

**Traditional Storage**: Store file → manually handle payments → hope provider keeps file
**PDP-Payments**: Store file → automatic payment escrow → cryptographic proof → automatic settlement

## 1. Complete Workflow Script

Create `complete-workflow.js`:

```javascript
// complete-workflow.js
import { Synapse } from 'synapse-sdk'
import { readFileSync } from 'fs'
import 'dotenv/config'

async function completeWorkflow() {
  console.log('🚀 Starting Complete PDP + Payments Workflow\n')
  
  // Initialize SDK
  const synapse = new Synapse({
    privateKey: process.env.PRIVATE_KEY,
    withCDN: true,
  })
  
  // === STEP 1: PAYMENT SETUP ===
  console.log('💰 Step 1: Payment Setup')
  console.log('─'.repeat(40))
  
  let balance = await synapse.balance()
  console.log(`Current balance: ${balance} USDFC`)
  
  // Ensure sufficient balance for storage
  const requiredBalance = 10
  if (balance < requiredBalance) {
    console.log(`💸 Depositing ${requiredBalance - balance} USDFC...`)
    balance = await synapse.deposit(requiredBalance - balance)
    console.log(`✅ Deposit successful! New balance: ${balance} USDFC`)
  }
  
  // === STEP 2: STORAGE WITH AUTOMATIC PAYMENT ESCROW ===
  console.log('\n📁 Step 2: Storage with Payment Escrow')
  console.log('─'.repeat(40))
  
  // Create storage service
  const storage = await synapse.createStorage({
    // Optional: specify preferred storage provider
    // storageProvider: 'f01234'
  })
  
  console.log(`Storage service created:`)
  console.log(`- Proof Set ID: ${storage.proofSetId}`)
  console.log(`- Storage Provider: ${storage.storageProvider}`)
  
  // Prepare file data (example: small text file)
  const fileData = new TextEncoder().encode('Hello PDP-Payments! This is my first stored file.')
  console.log(`File size: ${fileData.length} bytes`)
  
  // Upload with automatic payment escrow
  console.log('\n📤 Starting upload with payment escrow...')
  const uploadTask = storage.upload(fileData)
  
  // Track upload progress
  console.log('🔄 Generating CommP (Piece Commitment)...')
  const commp = await uploadTask.commp()
  console.log(`✅ CommP generated: ${commp}`)
  
  console.log('🔄 Storing with provider (payment escrowed)...')
  const sp = await uploadTask.store()
  console.log(`✅ Stored with provider: ${sp}`)
  
  console.log('🔄 Committing to blockchain...')
  const txHash = await uploadTask.done()
  console.log(`✅ Upload complete! Transaction: ${txHash}`)
  
  // === STEP 3: MONITOR AND VERIFY ===
  console.log('\n🔍 Step 3: Monitor Storage & Payments')
  console.log('─'.repeat(40))
  
  // Check updated balance (should be reduced by storage cost)
  const balanceAfterStorage = await synapse.balance()
  console.log(`Balance after storage: ${balanceAfterStorage} USDFC`)
  console.log(`Storage cost: ${balance - balanceAfterStorage} USDFC`)
  
  // === STEP 4: PAYMENT SETTLEMENT ===
  console.log('\n💸 Step 4: Payment Settlement')
  console.log('─'.repeat(40))
  
  console.log('Settling payments with storage provider...')
  const settlement = await storage.settlePayments()
  console.log(`✅ Settlement complete:`)
  console.log(`- Amount settled: ${settlement.settledAmount} USDFC`)
  console.log(`- Settlement epoch: ${settlement.epoch}`)
  
  // === STEP 5: FILE RETRIEVAL ===
  console.log('\n📥 Step 5: File Retrieval')
  console.log('─'.repeat(40))
  
  console.log('Downloading file with verification...')
  const retrievedData = await storage.download(commp, {
    noVerify: false, // Verify data integrity
    withCDN: true    // Use CDN if available
  })
  
  const retrievedText = new TextDecoder().decode(retrievedData)
  console.log(`✅ File retrieved successfully!`)
  console.log(`Retrieved content: "${retrievedText}"`)
  console.log(`Data integrity: ${retrievedText === 'Hello PDP-Payments! This is my first stored file.' ? '✅ VERIFIED' : '❌ CORRUPTED'}`)
  
  // === STEP 6: CLEANUP (OPTIONAL) ===
  console.log('\n🧹 Step 6: Cleanup (Optional)')
  console.log('─'.repeat(40))
  
  // Delete file from storage
  console.log('Deleting file from storage...')
  await storage.delete(commp)
  console.log('✅ File deleted from storage')
  
  // Withdraw remaining balance
  const finalBalance = await synapse.balance()
  if (finalBalance > 0) {
    console.log(`Withdrawing remaining ${finalBalance} USDFC...`)
    await synapse.withdraw(finalBalance)
    console.log('✅ Withdrawal complete')
  }
  
  console.log('\n🎉 Complete workflow finished successfully!')
  console.log('\nWhat happened:')
  console.log('1. ✅ Automatic payment escrow during upload')
  console.log('2. ✅ Cryptographic proof generation (CommP)')
  console.log('3. ✅ Blockchain commitment for verifiability')
  console.log('4. ✅ Automatic payment settlement with provider')
  console.log('5. ✅ Verified file retrieval with integrity check')
}

completeWorkflow().catch(console.error)
```

## 2. Run the Complete Workflow

```bash
node complete-workflow.js
```

**Expected Output:**
```
🚀 Starting Complete PDP + Payments Workflow

💰 Step 1: Payment Setup
────────────────────────────────────────
Current balance: 100 USDFC

📁 Step 2: Storage with Payment Escrow
────────────────────────────────────────
Storage service created:
- Proof Set ID: ps_abc123
- Storage Provider: f01234

File size: 52 bytes

📤 Starting upload with payment escrow...
🔄 Generating CommP (Piece Commitment)...
✅ CommP generated: baga6ea4seaqjtovkwk4myyzj56eztkh5pzsk5upksan6f5outesy62bsvl4dsha

🔄 Storing with provider (payment escrowed)...
✅ Stored with provider: f01234

🔄 Committing to blockchain...
✅ Upload complete! Transaction: 0x1234...abcd

🔍 Step 3: Monitor Storage & Payments
────────────────────────────────────────
Balance after storage: 100 USDFC
Storage cost: 0 USDFC

💸 Step 4: Payment Settlement
────────────────────────────────────────
Settling payments with storage provider...
✅ Settlement complete:
- Amount settled: 0.05 USDFC
- Settlement epoch: 12345

📥 Step 5: File Retrieval
────────────────────────────────────────
Downloading file with verification...
✅ File retrieved successfully!
Retrieved content: "Hello PDP-Payments! This is my first stored file."
Data integrity: ✅ VERIFIED

🧹 Step 6: Cleanup (Optional)
────────────────────────────────────────
Deleting file from storage...
✅ File deleted from storage
Withdrawing remaining 100 USDFC...
✅ Withdrawal complete

🎉 Complete workflow finished successfully!

What happened:
1. ✅ Automatic payment escrow during upload
2. ✅ Cryptographic proof generation (CommP)
3. ✅ Blockchain commitment for verifiability
4. ✅ Automatic payment settlement with provider
5. ✅ Verified file retrieval with integrity check
```

## 3. Key Concepts Explained

### 🔐 **CommP (Piece Commitment)**
- Cryptographic fingerprint of your file
- Used for verification and retrieval
- Generated automatically by SDK

### 💰 **Payment Escrow**
- USDFC automatically held during storage
- Released to provider after proof verification
- No manual payment coordination needed

### 🔍 **PDP (Proof of Data Possession)**
- Cryptographic proof your file is stored
- Verified on-chain for transparency
- Automatic monitoring by SDK

### 💸 **Settlement**
- Automatic payment to storage provider
- Based on actual storage duration
- Transparent on-chain settlement

## 4. SDK vs Raw Contracts Comparison

**This workflow with SDK: ~30 lines**
```javascript
const synapse = new Synapse({ privateKey })
const storage = await synapse.createStorage()
const uploadTask = storage.upload(data)
const commp = await uploadTask.commp()
await uploadTask.done()
await storage.settlePayments()
```

**Same workflow with raw contracts: ~200+ lines**
- Manual contract instantiation
- Complex payment coordination
- Manual proof submission
- Error-prone state management
- No automatic settlement

## 5. What's Next?

Continue to **[Step 4: Monitor & Verify](sdk-monitoring.md)** to learn:
- 📊 Real-time storage monitoring
- 🔍 Proof verification details
- 📈 Payment tracking and analytics
- 🚨 Error handling and recovery

## Troubleshooting

### File Upload Fails
- Check your balance has sufficient USDFC
- Ensure file size is within limits
- Verify network connectivity

### Payment Issues
- Confirm USDFC tokens in wallet
- Check private key is correct
- Verify you're on Calibration testnet

### Retrieval Fails
- Ensure CommP is correct
- Check storage provider is online
- Try with `noVerify: true` for debugging

Ready for monitoring and verification? **[Continue to Step 4 →](sdk-monitoring.md)**
