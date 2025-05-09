# Hot Vault Demo

The Hot Vault demo is a reference implementation that demonstrates how to build a data storage application using FilOz's [Provable Data Possession (PDP)](../pdp/concepts/overview.md) and [Payments](../payments/concepts/overview.md) systems.

## Overview

Hot Vault is a prototype for a data storage drive application that leverages Filecoin's verifiable storage, powered by Proof of Data Possession (PDP), payable with FIL-backed Stablecoin.

The demo showcases:

1. **Client-Side Integration**: How client applications can interact with the FilOz ecosystem
2. **Server-Side Implementation**: How storage providers can implement PDP and receive payments
3. **End-to-End Flow**: The complete flow from data upload to proof verification and payment

## Architecture

Hot Vault consists of two main components:

### Client Application

A web application that allows users to:
- Upload files for storage
- Monitor storage status
- View proof compliance
- Manage payments

### Server Component

A backend service that:
- Receives and stores files
- Creates and manages proof sets
- Submits proofs of data possession
- Receives payments through payment rails

## How It Works

### 1. Data Upload

When a user uploads a file to Hot Vault:

```javascript
// Client-side code for uploading a file
async function uploadFile(file) {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch('/api/upload', {
    method: 'POST',
    body: formData
  });
  
  const result = await response.json();
  return result.fileId;
}
```

The server receives the file and prepares it for storage:

```javascript
// Server-side code for handling file upload
app.post('/api/upload', async (req, res) => {
  // Save the file
  const fileId = await saveFile(req.file);
  
  // Create a CAR file
  const carFile = await createCARFile(fileId);
  
  // Calculate the CID
  const cid = await calculateCID(carFile);
  
  // Store metadata
  await storeMetadata(fileId, {
    cid,
    size: req.file.size,
    name: req.file.originalname
  });
  
  res.json({ fileId });
});
```

### 2. Payment Setup

After the file is uploaded, Hot Vault sets up a payment rail:

```javascript
// Server-side code for setting up payment
async function setupPayment(fileId, clientAddress) {
  // Get file metadata
  const metadata = await getMetadata(fileId);
  
  // Calculate payment rate based on file size
  const paymentRate = calculatePaymentRate(metadata.size);
  
  // Create a payment rail
  const railId = await createPaymentRail(
    tokenAddress,
    clientAddress,
    providerAddress,
    arbiterAddress,
    paymentRate,
    lockupPeriod,
    lockupFixed,
    commissionRate
  );
  
  // Store the rail ID with the file metadata
  await updateMetadata(fileId, { railId });
  
  return railId;
}
```

### 3. PDP Integration

Hot Vault creates a proof set in the PDP system:

```javascript
// Server-side code for setting up PDP
async function setupPDP(fileId, railId) {
  // Get file metadata
  const metadata = await getMetadata(fileId);
  
  // Encode payment information in extra data
  const extraData = ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address'],
    [railId, paymentsContractAddress]
  );
  
  // Create a proof set
  const proofSetId = await createProofSet(
    pdpServiceAddress,
    extraData
  );
  
  // Add the file data to the proof set
  await addRootsToPDP(proofSetId, metadata.cid, metadata.size);
  
  // Store the proof set ID with the file metadata
  await updateMetadata(fileId, { proofSetId });
  
  return proofSetId;
}
```

### 4. Proof Submission

The server regularly submits proofs of data possession:

```javascript
// Server-side code for submitting proofs
async function submitProofs() {
  // Get all active proof sets
  const proofSets = await getActiveProofSets();
  
  for (const proofSet of proofSets) {
    // Check if it's time to submit a proof
    const nextChallengeEpoch = await getNextChallengeEpoch(proofSet.id);
    const currentEpoch = await getCurrentEpoch();
    
    if (currentEpoch >= nextChallengeEpoch) {
      // Generate proofs
      const proofs = await generateProofs(proofSet.id);
      
      // Submit proofs
      await submitPDPProofs(proofSet.id, proofs);
      
      // Log the proof submission
      await logProofSubmission(proofSet.id, currentEpoch);
    }
  }
}
```

### 5. Payment Settlement

Payments are settled regularly:

```javascript
// Server-side code for settling payments
async function settlePayments() {
  // Get all active payment rails
  const rails = await getActiveRails();
  
  for (const rail of rails) {
    // Get the last settled epoch
    const lastSettledEpoch = await getLastSettledEpoch(rail.id);
    const currentEpoch = await getCurrentEpoch();
    
    // Settle if enough time has passed
    if (currentEpoch - lastSettledEpoch >= settlementInterval) {
      await settleRail(rail.id, currentEpoch);
      
      // Log the settlement
      await logSettlement(rail.id, lastSettledEpoch, currentEpoch);
    }
  }
}
```

## User Interface

The Hot Vault demo includes a user interface that allows users to:

1. **Upload Files**: Drag and drop files for storage
2. **View Files**: See a list of stored files with metadata
3. **Monitor Storage**: Check the status of each file's storage
4. **View Proofs**: See the history of proof submissions
5. **Track Payments**: Monitor payment flows and adjustments

## Implementation Details

### Client-Side Technologies

- React.js for the user interface
- ethers.js for blockchain interactions
- MetaMask for wallet integration

### Server-Side Technologies

- Node.js for the backend server
- IPFS for content-addressable storage
- PDP Tool for proof generation and submission

## Running the Demo

To run the Hot Vault demo locally:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/FilOzone/hotvault-demo.git
   cd hotvault-demo
   ```

2. **Install Dependencies**:
   ```bash
   # Install server dependencies
   cd server
   npm install
   
   # Install client dependencies
   cd ../client
   npm install
   ```

3. **Configure Environment**:
   ```bash
   # Server configuration
   cd ../server
   cp .env.example .env
   # Edit .env with your configuration
   
   # Client configuration
   cd ../client
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start the Server**:
   ```bash
   cd ../server
   npm start
   ```

5. **Start the Client**:
   ```bash
   cd ../client
   npm start
   ```

6. **Access the Demo**:
   Open your browser and navigate to `http://localhost:3000`

## Integration Points

The Hot Vault demo integrates with the FilOz ecosystem at these key points:

1. **Payments Contract**: Creates and manages payment rails
2. **PDP Verifier**: Creates proof sets and verifies proofs
3. **PDP Service**: Defines SLA terms and tracks compliance
4. **Arbiter Contract**: Adjusts payments based on proof compliance

## Code Examples

### Creating a Payment Rail

```javascript
async function createPaymentRail(
  tokenAddress,
  clientAddress,
  providerAddress,
  arbiterAddress,
  paymentRate,
  lockupPeriod,
  lockupFixed,
  commissionRate
) {
  const paymentsContract = new ethers.Contract(
    paymentsContractAddress,
    paymentsAbi,
    signer
  );
  
  const tx = await paymentsContract.createRail(
    tokenAddress,
    clientAddress,
    providerAddress,
    arbiterAddress,
    paymentRate,
    lockupPeriod,
    lockupFixed,
    commissionRate
  );
  
  const receipt = await tx.wait();
  const railId = receipt.events[0].args.railId;
  
  return railId;
}
```

### Creating a Proof Set

```javascript
async function createProofSet(pdpServiceAddress, extraData) {
  const pdpVerifier = new ethers.Contract(
    pdpVerifierAddress,
    pdpVerifierAbi,
    signer
  );
  
  const sybilFee = await pdpVerifier.sybilFee();
  
  const tx = await pdpVerifier.createProofSet(
    pdpServiceAddress,
    extraData,
    { value: sybilFee }
  );
  
  const receipt = await tx.wait();
  const proofSetId = receipt.events[0].args.setId;
  
  return proofSetId;
}
```

## Next Steps

- [Clone the Hot Vault Demo Repository](https://github.com/FilOzone/hotvault-demo)
- [Explore the PDP System](../pdp/concepts/overview.md)
- [Learn About the Payments System](../payments/concepts/overview.md)
- [Understand PDP-Payments Integration](../integration/pdp-payments.md)
- [Build Your Own Application](../integration/building-on-filoz.md)
