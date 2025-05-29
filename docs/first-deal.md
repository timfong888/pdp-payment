# Creating Your First Storage Deal

This guide walks you through the process of creating your first storage deal using the FilOz ecosystem.

## Prerequisites

Before you begin, make sure you have:
- Completed the [Setting Up Your Environment](setup.md) guide
- Some test tokens on Filecoin Calibration Testnet
- A file you want to store

## Step 1: Prepare Your Data

First, you need to prepare your data for storage:

```javascript
const fs = require('fs');
const { CarWriter } = require('@ipld/car');
const { importer } = require('ipfs-unixfs-importer');
const { CID } = require('multiformats/cid');
const { sha256 } = require('multiformats/hashes/sha2');
const { encode } = require('multiformats/block');
const { code } = require('@ipld/dag-cbor');

async function prepareData(filePath) {
  // Read the file
  const fileData = fs.readFileSync(filePath);
  
  // Import the file to create a DAG
  const options = {
    cidVersion: 1,
    hashAlg: sha256.code,
    rawLeaves: true,
    wrapWithDirectory: false
  };
  
  const chunks = [];
  for await (const chunk of importer([{ path: filePath, content: fileData }], options)) {
    chunks.push(chunk);
  }
  
  // Get the root CID
  const rootCid = chunks[chunks.length - 1].cid;
  
  // Create a CAR file
  const { writer, out } = await CarWriter.create([rootCid]);
  const carParts = [];
  
  for await (const chunk of out) {
    carParts.push(chunk);
  }
  
  // Write all chunks to the CAR file
  for (const chunk of chunks) {
    const block = await encode({
      value: chunk.node,
      codec: code,
      hasher: sha256
    });
    await writer.put(block);
  }
  
  await writer.close();
  
  // Combine all parts into a single buffer
  const carFile = Buffer.concat(carParts);
  
  // Write the CAR file to disk
  fs.writeFileSync(`${filePath}.car`, carFile);
  
  return {
    cid: rootCid.toString(),
    carFile,
    carSize: carFile.length
  };
}
```

## Step 2: Create a Payment Rail

Next, create a payment rail to fund the storage:

```javascript
async function createPaymentRail(tokenAddress, payeeAddress) {
  // First, approve the Payments contract to spend your tokens
  const tokenAbi = ['function approve(address spender, uint256 amount) returns (bool)'];
  const token = new ethers.Contract(tokenAddress, tokenAbi, wallet);
  
  const approvalAmount = ethers.utils.parseUnits('100', 6); // 100 USDC
  const approveTx = await token.approve(paymentsAddress, approvalAmount);
  await approveTx.wait();
  console.log('Token approval confirmed');
  
  // Deposit funds into the Payments contract
  const depositAmount = ethers.utils.parseUnits('10', 6); // 10 USDC
  const depositTx = await payments.deposit(tokenAddress, wallet.address, depositAmount);
  await depositTx.wait();
  console.log('Deposit confirmed');
  
  // Create the payment rail
  const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDC per epoch
  const lockupPeriod = 2880; // 1 day in epochs
  const lockupFixed = ethers.utils.parseUnits('1', 6); // 1 USDC fixed lockup
  const commissionRate = 0; // No commission
  
  const tx = await payments.createRail(
    tokenAddress,
    wallet.address, // Your address as payer
    payeeAddress,   // Storage provider address as payee
    ethers.constants.AddressZero, // No arbiter for now
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

## Step 3: Create a Proof Set

Create a proof set in the PDP system:

```javascript
async function createProofSet(railId) {
  // Encode the payment rail ID in the extra data
  const extraData = ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address'],
    [railId, paymentsAddress]
  );
  
  // Calculate the sybil fee
  const sybilFee = await pdpVerifier.sybilFee();
  
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

## Step 4: Make a Deal Proposal

Now, create a deal proposal using the Client Contract:

```javascript
async function makeDealProposal(cid, carSize, locationRef) {
  // Client Contract address
  const clientContractAddress = '0x...'; // Replace with actual address
  const clientContractAbi = require('./abis/DealClient.json');
  const clientContract = new ethers.Contract(clientContractAddress, clientContractAbi, wallet);
  
  // Create a deal request
  const dealRequest = {
    piece_cid: cid,
    piece_size: carSize,
    verified_deal: false,
    label: 'My first deal',
    start_epoch: (await provider.getBlockNumber()) + 100, // Start 100 epochs from now
    end_epoch: (await provider.getBlockNumber()) + 525600, // Store for approximately 1 year
    storage_price_per_epoch: ethers.utils.parseEther('0.0000001'),
    provider_collateral: ethers.utils.parseEther('0.1'),
    client_collateral: ethers.utils.parseEther('0.05'),
    extra_params_version: 1,
    extra_params: {
      location_ref: locationRef, // URL where the storage provider can retrieve the data
      car_size: carSize,
      skip_ipni_announce: false,
      remove_unsealed_copy: false
    }
  };
  
  // Make the deal proposal
  const tx = await clientContract.makeDealProposal(dealRequest);
  const receipt = await tx.wait();
  
  // Get the deal ID from the event logs
  const dealId = receipt.events[0].args.id;
  console.log(`Created deal proposal with ID: ${dealId}`);
  
  return dealId;
}
```

## Step 5: Upload Your Data

Upload your CAR file to a location accessible by the storage provider:

```javascript
async function uploadData(carFilePath) {
  // This is a simplified example - in a real application, you would:
  // 1. Upload the CAR file to a web server, IPFS, or other storage
  // 2. Return the URL or reference to the file
  
  // For this example, we'll assume you're uploading to a web server
  console.log(`Upload your CAR file (${carFilePath}) to a web server`);
  console.log('Then provide the URL to the storage provider');
  
  // In a real application, you would use a library like axios to upload the file
  const uploadUrl = 'https://example.com/uploads/myfile.car';
  
  return uploadUrl;
}
```

## Step 6: Putting It All Together

Here's how to put all the steps together:

```javascript
async function createStorageDeal(filePath, storageProviderAddress) {
  try {
    // Prepare the data
    console.log(`Preparing data from ${filePath}...`);
    const { cid, carFile, carSize } = await prepareData(filePath);
    console.log(`Data prepared with CID: ${cid}`);
    
    // Upload the data
    console.log('Uploading data...');
    const locationRef = await uploadData(`${filePath}.car`);
    console.log(`Data uploaded to: ${locationRef}`);
    
    // Create a payment rail
    console.log('Creating payment rail...');
    const railId = await createPaymentRail('0xUSDCAddress', storageProviderAddress);
    
    // Create a proof set
    console.log('Creating proof set...');
    const proofSetId = await createProofSet(railId);
    
    // Make a deal proposal
    console.log('Making deal proposal...');
    const dealId = await makeDealProposal(cid, carSize, locationRef);
    
    console.log('\nStorage deal created successfully!');
    console.log('-----------------------------------');
    console.log(`File: ${filePath}`);
    console.log(`CID: ${cid}`);
    console.log(`Payment Rail ID: ${railId}`);
    console.log(`Proof Set ID: ${proofSetId}`);
    console.log(`Deal ID: ${dealId}`);
    
    return { cid, railId, proofSetId, dealId };
  } catch (error) {
    console.error('Error creating storage deal:', error);
    throw error;
  }
}

// Usage
createStorageDeal('myfile.txt', '0xStorageProviderAddress')
  .then(result => console.log('Done!'))
  .catch(error => console.error('Failed:', error));
```

## Next Steps

After creating your first storage deal:

1. Learn how to [Monitor Your Storage Deal](pdp/guides/verifying-proofs.md)
2. Understand how to [Implement a Custom Arbiter](payments/guides/custom-arbiter.md)
3. Explore the [Hot Vault Demo](examples/hot-vault.md) for a complete implementation

For more information on the components used in this guide:
- [Understanding PDP](pdp-overview.md)
- [Payment Mechanisms](payments.md)
- [Client Contract Documentation](https://github.com/FilOzone/client-contract)
