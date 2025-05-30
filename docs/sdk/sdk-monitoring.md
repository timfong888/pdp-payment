# Step 4: Monitor & Verify Storage

This is the fourth step in your Developer Path - learn how to monitor your stored files, verify proofs, and track payments in real-time.

## Prerequisites

- ✅ **Completed [Step 3: Complete Workflow](sdk-workflow.md)** - You've stored and retrieved files
- ✅ **Understanding of CommP** - Cryptographic file fingerprints

## 🎯 What You'll Learn

- 📊 **Real-time monitoring** of storage status
- 🔍 **Proof verification** for data integrity
- 💰 **Payment tracking** and settlement history
- 🚨 **Error detection** and recovery strategies

## 1. Storage Monitoring Dashboard

Create `monitoring-dashboard.js`:

```javascript
// monitoring-dashboard.js
import { Synapse } from 'synapse-sdk'
import 'dotenv/config'

class StorageMonitor {
  constructor() {
    this.synapse = new Synapse({
      privateKey: process.env.PRIVATE_KEY,
      withCDN: true,
    })
    this.storage = null
    this.storedFiles = new Map() // Track files by CommP
  }
  
  async initialize() {
    console.log('🔧 Initializing Storage Monitor...')
    this.storage = await this.synapse.createStorage()
    console.log(`✅ Connected to storage service: ${this.storage.storageProvider}`)
    return this
  }
  
  async storeAndTrack(data, filename) {
    console.log(`\n📤 Storing: ${filename}`)
    console.log('─'.repeat(50))
    
    const uploadTask = this.storage.upload(data)
    
    // Track progress
    const commp = await uploadTask.commp()
    console.log(`🔐 CommP: ${commp}`)
    
    const sp = await uploadTask.store()
    console.log(`📦 Stored with: ${sp}`)
    
    const txHash = await uploadTask.done()
    console.log(`⛓️  Transaction: ${txHash}`)
    
    // Add to tracking
    this.storedFiles.set(commp.toString(), {
      filename,
      commp,
      storageProvider: sp,
      txHash,
      uploadTime: new Date(),
      size: data.length,
      verified: false
    })
    
    console.log(`✅ ${filename} stored and tracked`)
    return commp
  }
  
  async verifyFile(commp) {
    console.log(`\n🔍 Verifying file: ${commp}`)
    console.log('─'.repeat(50))
    
    const fileInfo = this.storedFiles.get(commp.toString())
    if (!fileInfo) {
      console.log('❌ File not found in tracking system')
      return false
    }
    
    try {
      // Attempt to download and verify
      console.log('📥 Downloading for verification...')
      const retrievedData = await this.storage.download(commp, {
        noVerify: false, // Enable verification
        withCDN: true
      })
      
      // Check size matches
      const sizeMatch = retrievedData.length === fileInfo.size
      console.log(`📏 Size check: ${sizeMatch ? '✅' : '❌'} (${retrievedData.length}/${fileInfo.size} bytes)`)
      
      // Update tracking
      fileInfo.verified = sizeMatch
      fileInfo.lastVerified = new Date()
      
      console.log(`✅ Verification complete: ${sizeMatch ? 'PASSED' : 'FAILED'}`)
      return sizeMatch
      
    } catch (error) {
      console.log(`❌ Verification failed: ${error.message}`)
      fileInfo.verified = false
      fileInfo.lastError = error.message
      return false
    }
  }
  
  async checkBalance() {
    console.log('\n💰 Balance Check')
    console.log('─'.repeat(50))
    
    const balance = await this.synapse.balance()
    console.log(`Current balance: ${balance} USDFC`)
    
    if (balance < 5) {
      console.log('⚠️  Low balance warning! Consider depositing more USDFC')
    }
    
    return balance
  }
  
  async settleAllPayments() {
    console.log('\n💸 Payment Settlement')
    console.log('─'.repeat(50))
    
    try {
      const settlement = await this.storage.settlePayments()
      console.log(`✅ Settlement successful:`)
      console.log(`   Amount: ${settlement.settledAmount} USDFC`)
      console.log(`   Epoch: ${settlement.epoch}`)
      return settlement
    } catch (error) {
      console.log(`❌ Settlement failed: ${error.message}`)
      return null
    }
  }
  
  displayDashboard() {
    console.log('\n📊 Storage Dashboard')
    console.log('═'.repeat(60))
    
    if (this.storedFiles.size === 0) {
      console.log('No files currently tracked')
      return
    }
    
    console.log(`Total files tracked: ${this.storedFiles.size}`)
    console.log('')
    
    for (const [commp, fileInfo] of this.storedFiles) {
      const status = fileInfo.verified ? '✅ VERIFIED' : '❓ UNVERIFIED'
      const age = Math.round((Date.now() - fileInfo.uploadTime) / 1000 / 60) // minutes
      
      console.log(`📁 ${fileInfo.filename}`)
      console.log(`   CommP: ${commp.substring(0, 20)}...`)
      console.log(`   Status: ${status}`)
      console.log(`   Size: ${fileInfo.size} bytes`)
      console.log(`   Age: ${age} minutes`)
      console.log(`   Provider: ${fileInfo.storageProvider}`)
      if (fileInfo.lastError) {
        console.log(`   ⚠️  Last Error: ${fileInfo.lastError}`)
      }
      console.log('')
    }
  }
  
  async runMonitoringCycle() {
    console.log('\n🔄 Running Monitoring Cycle')
    console.log('═'.repeat(60))
    
    // Check balance
    await this.checkBalance()
    
    // Verify all tracked files
    for (const [commp, fileInfo] of this.storedFiles) {
      await this.verifyFile(commp)
    }
    
    // Settle payments
    await this.settleAllPayments()
    
    // Display dashboard
    this.displayDashboard()
  }
}

// Demo usage
async function monitoringDemo() {
  console.log('🚀 Storage Monitoring Demo')
  console.log('═'.repeat(60))
  
  const monitor = await new StorageMonitor().initialize()
  
  // Store some test files
  const file1 = new TextEncoder().encode('Hello from file 1!')
  const file2 = new TextEncoder().encode('This is file 2 with more content for testing.')
  
  const commp1 = await monitor.storeAndTrack(file1, 'test-file-1.txt')
  const commp2 = await monitor.storeAndTrack(file2, 'test-file-2.txt')
  
  // Run monitoring cycle
  await monitor.runMonitoringCycle()
  
  console.log('\n🎉 Monitoring demo complete!')
  console.log('\nNext steps:')
  console.log('- Run monitoring cycles periodically')
  console.log('- Set up alerts for verification failures')
  console.log('- Monitor balance and auto-deposit if needed')
}

monitoringDemo().catch(console.error)
```

## 2. Run the Monitoring Demo

```bash
node monitoring-dashboard.js
```

**Expected Output:**
```
🚀 Storage Monitoring Demo
═══════════════════════════════════════════════════════════

🔧 Initializing Storage Monitor...
✅ Connected to storage service: f01234

📤 Storing: test-file-1.txt
──────────────────────────────────────────────────
🔐 CommP: baga6ea4seaqjtovkwk4myyzj56eztkh5pzsk5upksan6f5outesy62bsvl4dsha
📦 Stored with: f01234
⛓️  Transaction: 0x1234...abcd
✅ test-file-1.txt stored and tracked

📤 Storing: test-file-2.txt
──────────────────────────────────────────────────
🔐 CommP: baga6ea4seaqjtovkwk4myyzj56eztkh5pzsk5upksan6f5outesy62bsvl4dsha
📦 Stored with: f01234
⛓️  Transaction: 0x5678...efgh
✅ test-file-2.txt stored and tracked

🔄 Running Monitoring Cycle
═══════════════════════════════════════════════════════════

💰 Balance Check
──────────────────────────────────────────────────
Current balance: 100 USDFC

🔍 Verifying file: baga6ea4seaqjtovkwk4myyzj56eztkh5pzsk5upksan6f5outesy62bsvl4dsha
──────────────────────────────────────────────────
📥 Downloading for verification...
📏 Size check: ✅ (18/18 bytes)
✅ Verification complete: PASSED

🔍 Verifying file: baga6ea4seaqjtovkwk4myyzj56eztkh5pzsk5upksan6f5outesy62bsvl4dsha
──────────────────────────────────────────────────
📥 Downloading for verification...
📏 Size check: ✅ (42/42 bytes)
✅ Verification complete: PASSED

💸 Payment Settlement
──────────────────────────────────────────────────
✅ Settlement successful:
   Amount: 0.05 USDFC
   Epoch: 12345

📊 Storage Dashboard
═══════════════════════════════════════════════════════════
Total files tracked: 2

📁 test-file-1.txt
   CommP: baga6ea4seaqjtovkwk4...
   Status: ✅ VERIFIED
   Size: 18 bytes
   Age: 1 minutes
   Provider: f01234

📁 test-file-2.txt
   CommP: baga6ea4seaqjtovkwk4...
   Status: ✅ VERIFIED
   Size: 42 bytes
   Age: 0 minutes
   Provider: f01234

🎉 Monitoring demo complete!

Next steps:
- Run monitoring cycles periodically
- Set up alerts for verification failures
- Monitor balance and auto-deposit if needed
```

## 3. Production Monitoring Patterns

### 🔄 **Periodic Monitoring**
```javascript
// Run monitoring every 10 minutes
setInterval(async () => {
  await monitor.runMonitoringCycle()
}, 10 * 60 * 1000)
```

### 🚨 **Alert System**
```javascript
async function checkAndAlert() {
  const balance = await synapse.balance()
  
  if (balance < 5) {
    console.log('🚨 ALERT: Low balance!')
    // Send notification, auto-deposit, etc.
  }
  
  // Check for verification failures
  for (const [commp, fileInfo] of storedFiles) {
    if (!fileInfo.verified) {
      console.log(`🚨 ALERT: File verification failed: ${fileInfo.filename}`)
      // Handle verification failure
    }
  }
}
```

### 📈 **Analytics Tracking**
```javascript
function generateReport() {
  const totalFiles = storedFiles.size
  const verifiedFiles = Array.from(storedFiles.values()).filter(f => f.verified).length
  const totalSize = Array.from(storedFiles.values()).reduce((sum, f) => sum + f.size, 0)
  
  console.log(`📈 Storage Report:`)
  console.log(`   Files: ${verifiedFiles}/${totalFiles} verified`)
  console.log(`   Total size: ${totalSize} bytes`)
  console.log(`   Success rate: ${(verifiedFiles/totalFiles*100).toFixed(1)}%`)
}
```

## 4. Key Monitoring Concepts

### 🔐 **CommP Verification**
- **What**: Cryptographic proof your file hasn't changed
- **How**: SDK downloads and verifies against original CommP
- **Why**: Ensures data integrity and provider honesty

### 💰 **Payment Tracking**
- **Escrow**: Funds held during storage period
- **Settlement**: Automatic payment to provider after proof
- **Balance**: Monitor to ensure continuous service

### 📊 **Storage Health**
- **Verification Rate**: % of files that pass integrity checks
- **Response Time**: How quickly files can be retrieved
- **Provider Reliability**: Track which providers perform best

## 5. Error Handling Strategies

### ❌ **Verification Failures**
```javascript
if (!verified) {
  // 1. Retry verification
  // 2. Try different retrieval method
  // 3. Contact storage provider
  // 4. Consider re-uploading file
}
```

### 💸 **Payment Issues**
```javascript
if (balance < threshold) {
  // 1. Auto-deposit from external wallet
  // 2. Alert administrators
  // 3. Pause new uploads
}
```

### 🔌 **Network Issues**
```javascript
try {
  await storage.download(commp)
} catch (error) {
  if (error.message.includes('network')) {
    // Retry with exponential backoff
    await retryWithBackoff(() => storage.download(commp))
  }
}
```

## 6. What's Next?

You've mastered the core PDP-Payments workflow! For production deployment, continue to **[Step 5: Production Deployment](sdk-production.md)** to learn:

- 🏭 **Production configuration** and best practices
- 🔒 **Security considerations** for private keys and payments
- 📈 **Scaling strategies** for high-volume applications
- 🔧 **Integration patterns** with existing systems

## Troubleshooting

### Verification Always Fails
- Check network connectivity
- Verify storage provider is online
- Try with `noVerify: true` to isolate issue

### Balance Decreases Unexpectedly
- Check settlement history
- Monitor for unauthorized transactions
- Verify private key security

### Files Become Unretrievable
- Check storage provider status
- Verify CommP is correct
- Consider provider redundancy

Ready for production? **[Continue to Step 5 →](sdk-production.md)**
