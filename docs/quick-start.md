# Step 3: Install Synapse SDK

This is the third step in your Golden Path. You'll create a local application using the Synapse SDK to interact with Filecoin storage providers and the PDP-Payments system.

## Prerequisites

- ✅ Completed [Step 1: Setup Wallet & USDFC](setup.md)
- ✅ Completed [Step 2: Configure JSON-RPC](setup-detailed.md)
- **Node.js** (v18 or later) installed
- **npm** (v9 or later) installed

## 1. Understanding the Synapse SDK

The Synapse SDK provides a simple JavaScript/TypeScript interface for:
- **Binary Storage**: Store and retrieve files up to specified size limits
- **PDP Verification**: Cryptographic proofs ensure your data remains available
- **Payment Management**: Deposit, withdraw, and settle payments in USDFC
- **Optional CDN**: Pay extra for CDN-accelerated retrievals

### Key Features
- Simple API for file upload/download
- Automatic payment handling
- Progress tracking for uploads
- Built-in proof verification

## 2. Create Your Local App

### Initialize a New Project

```bash
# Create a new directory for your app
mkdir my-storage-app
cd my-storage-app

# Initialize npm project
npm init -y

# Install the Synapse SDK (currently using mock implementation)
npm install synapse-sdk

# Install additional dependencies
npm install dotenv fs-extra
```

### Project Structure

Your project should look like this:
```
my-storage-app/
├── package.json
├── .env
├── index.js
├── upload-file.js
└── files/
    └── (your test files)
```

## 3. Configure Your Environment

### Create Environment File

```bash
touch .env
```

### Add Configuration

```bash
# Wallet Configuration (from Step 2)
PRIVATE_KEY=your_private_key_here_without_0x_prefix

# Synapse SDK Configuration
SYNAPSE_PRIVATE_KEY=your_private_key_here_without_0x_prefix
SYNAPSE_WITH_CDN=true
SYNAPSE_RPC_API=https://api.calibration.node.glif.io/rpc/v1
SYNAPSE_SERVICE_CONTRACT=0x6170dE2b09b404776197485F3dc6c968Ef948505
```

## 4. Create Your First Synapse App

### Basic Setup Script

Create `index.js`:

```javascript
// index.js
require('dotenv').config();
const { Synapse } = require('synapse-sdk');
const fs = require('fs-extra');
const path = require('path');

async function main() {
  console.log('🚀 Starting Synapse SDK Demo...');

  // Initialize Synapse
  const synapse = new Synapse({
    privateKey: process.env.SYNAPSE_PRIVATE_KEY,
    withCDN: process.env.SYNAPSE_WITH_CDN === 'true',
    rpcAPI: process.env.SYNAPSE_RPC_API,
    serviceContract: process.env.SYNAPSE_SERVICE_CONTRACT
  });

  console.log('✅ Synapse SDK initialized');

  // Check and manage balance
  console.log('💰 Checking balance...');
  let balance = await synapse.balance();
  console.log(`Current balance: ${balance} USDFC`);

  if (balance < 50) {
    console.log('💳 Depositing funds...');
    await synapse.deposit(50 - balance);
    balance = await synapse.balance();
    console.log(`New balance: ${balance} USDFC`);
  }

  // Create a storage service instance
  console.log('🗄️ Creating storage service...');
  const storage = await synapse.createStorage();
  console.log('✅ Storage service created');

  console.log('\n🎉 Setup complete! Ready to store files.');
  console.log('\nNext steps:');
  console.log('1. Run: node upload-file.js');
  console.log('2. Follow the prompts to upload a file');
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('❌ Error:', error.message);
    process.exit(1);
  });
```

## 5. Create File Upload Script

### File Upload Implementation

Create `upload-file.js`:

```javascript
// upload-file.js
require('dotenv').config();
const { Synapse } = require('synapse-sdk');
const fs = require('fs-extra');
const path = require('path');

async function uploadFile() {
  try {
    console.log('📁 File Upload Demo');

    // Initialize Synapse
    const synapse = new Synapse({
      privateKey: process.env.SYNAPSE_PRIVATE_KEY,
      withCDN: process.env.SYNAPSE_WITH_CDN === 'true'
    });

    // Create storage service
    const storage = await synapse.createStorage();

    // Create test file if it doesn't exist
    const filesDir = path.join(__dirname, 'files');
    await fs.ensureDir(filesDir);

    const testFilePath = path.join(filesDir, 'test-image.txt');
    if (!await fs.pathExists(testFilePath)) {
      const testContent = `Hello from Synapse SDK!
This is a test file uploaded on ${new Date().toISOString()}
File size: ${Math.random() * 1000} bytes
Random data: ${Math.random().toString(36).substring(7)}`;

      await fs.writeFile(testFilePath, testContent);
      console.log(`📝 Created test file: ${testFilePath}`);
    }

    // Read file as binary data
    const fileBuffer = await fs.readFile(testFilePath);
    const data = new Uint8Array(fileBuffer);

    console.log(`📤 Uploading file: ${path.basename(testFilePath)} (${data.length} bytes)`);

    // Upload binary data
    const uploadTask = storage.upload(data);

    // Track upload progress
    console.log('🔄 Generating CommP...');
    const commp = await uploadTask.commp();
    console.log(`✅ Generated CommP: ${commp}`);

    console.log('🏪 Finding storage provider...');
    const sp = await uploadTask.store();
    console.log(`✅ Stored with provider: ${sp}`);

    console.log('⏳ Finalizing upload...');
    const txHash = await uploadTask.done();
    console.log(`✅ Upload complete! Transaction: ${txHash}`);

    // Store the CommP for later retrieval
    const metadataPath = path.join(filesDir, 'uploaded-files.json');
    let metadata = {};

    if (await fs.pathExists(metadataPath)) {
      metadata = await fs.readJson(metadataPath);
    }

    metadata[path.basename(testFilePath)] = {
      commp: commp,
      uploadDate: new Date().toISOString(),
      txHash: txHash,
      size: data.length
    };

    await fs.writeJson(metadataPath, metadata, { spaces: 2 });
    console.log(`📋 Metadata saved to: ${metadataPath}`);

    return { commp, txHash };

  } catch (error) {
    console.error('❌ Upload failed:', error.message);
    throw error;
  }
}

// Run if called directly
if (require.main === module) {
  uploadFile()
    .then(({ commp, txHash }) => {
      console.log('\n🎉 Upload successful!');
      console.log(`CommP: ${commp}`);
      console.log(`Transaction: ${txHash}`);
      console.log('\nNext: Try downloading with node download-file.js');
    })
    .catch(error => {
      console.error('❌ Error:', error.message);
      process.exit(1);
    });
}

module.exports = { uploadFile };
```

## 6. Test Your Setup

### Run the Basic Setup

```bash
node index.js
```

**Expected Output:**
```
🚀 Starting Synapse SDK Demo...
[Mock] Synapse initialized with options: { withCDN: true, rpcAPI: 'https://api.calibration.node.glif.io/rpc/v1', serviceContract: '0x6170dE2b09b404776197485F3dc6c968Ef948505' }
✅ Synapse SDK initialized
💰 Checking balance...
[Mock] Checking balance...
Current balance: 100 USDFC
🗄️ Creating storage service...
[Mock] Creating storage service...
[Mock] Storage service created with proofSetId: ps_abc123, SP: f01234
✅ Storage service created

🎉 Setup complete! Ready to store files.

Next steps:
1. Run: node upload-file.js
2. Follow the prompts to upload a file
```

### Run the File Upload

```bash
node upload-file.js
```

**Expected Output:**
```
📁 File Upload Demo
📝 Created test file: /path/to/files/test-image.txt
📤 Uploading file: test-image.txt (123 bytes)
🔄 Generating CommP...
[Mock] Generating CommP for 123 bytes...
✅ Generated CommP: baga6ea4seaqao7s73y24kcutaosvacpdjgfe5pw2zvogkbo6kqj375dposbngqq
🏪 Finding storage provider...
[Mock] Finding storage provider...
✅ Stored with provider: f01234
⏳ Finalizing upload...
[Mock] Finalizing upload...
✅ Upload complete! Transaction: 0x1234567890abcdef...
📋 Metadata saved to: /path/to/files/uploaded-files.json

🎉 Upload successful!
CommP: baga6ea4seaqao7s73y24kcutaosvacpdjgfe5pw2zvogkbo6kqj375dposbngqq
Transaction: 0x1234567890abcdef...

Next: Try downloading with node download-file.js
```

## 7. Understanding the SDK Flow

### What Just Happened?

1. **Initialization**: The SDK connected to the Filecoin network using your configuration
2. **Balance Check**: Verified you have sufficient USDFC for storage payments
3. **Storage Service**: Created a storage service instance linked to a storage provider
4. **File Upload**:
   - Generated a CommP (Commitment of Piece) - a cryptographic proof of your data
   - Found an available storage provider
   - Initiated the storage deal
   - Returned a transaction hash for verification

### Key Concepts

- **CommP**: A unique identifier for your data that enables proof verification
- **Storage Provider (SP)**: The entity that will store your data
- **Proof Set**: A collection of data that will be proven together
- **Payment Rail**: The mechanism for paying the storage provider

## Troubleshooting

### Common Issues

**SDK Import Error**
```bash
npm install synapse-sdk --save
```

**Environment Variables Not Found**
- Ensure your `.env` file is in the project root
- Check that variable names match exactly

**Balance Issues**
- Verify you have USDFC tokens from Step 1
- Check your wallet connection

**File Upload Fails**
- Ensure the `files/` directory exists
- Check file permissions

## Next Steps

🎉 **Congratulations!** You've completed Step 3 of the Golden Path.

**Next**: [Step 4: Hot Vault Demo Reference](examples/hot-vault.md) - Explore a complete implementation with code snippets

## Additional Resources

- [Synapse SDK Documentation](https://github.com/FilOzone/synapse-sdk)
- [Understanding CommP](https://docs.filecoin.io/basics/the-blockchain/proofs/)
- [Storage Provider Guide](https://docs.filecoin.io/storage-providers/basics/)
