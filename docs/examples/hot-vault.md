# Step 4: Hot Vault Demo Reference

This is the fourth step in your Golden Path. You'll explore the Hot Vault demo - a complete reference implementation that demonstrates how to build a modern web3 storage application using the PDP-Payments system.

**🔗 Live Demo Repository:** [https://github.com/FilOzone/hotvault-demo](https://github.com/FilOzone/hotvault-demo)

> **💡 Looking for a modern serverless approach?** Check out the [Wagmi-Vercel Hot Vault Guide](wagmi-vercel-hotvault.md) for a Docker-free, serverless implementation using Wagmi v2 and Vercel deployment.

## Prerequisites

- ✅ Completed [Step 1: Setup Wallet & USDFC](../setup.md)
- ✅ Completed [Step 2: Configure JSON-RPC](../setup-detailed.md)
- ✅ Completed [Step 3: Install Synapse SDK](../quick-start.md)
- **Understanding of React/Next.js** (helpful but not required)

## What is Hot Vault?

Hot Vault is a **production-ready reference implementation** that demonstrates:

1. **Modern Web3 UX**: Seamless wallet connection with Wagmi + MetaMask
2. **File Storage**: Upload photos from your desktop to Filecoin storage providers
3. **Cryptographic Proofs**: Real-time verification that your files remain stored
4. **Automatic Payments**: USDFC payments to storage providers based on proof compliance
5. **Full-Stack Architecture**: Next.js frontend + API routes + blockchain integration

### Key Features

- 🔐 **Wallet Integration**: Connect with MetaMask using modern Wagmi patterns
- 📁 **Drag & Drop Upload**: Intuitive file upload with progress tracking
- 🔍 **Proof Monitoring**: Real-time dashboard showing storage proof status
- 💰 **Payment Tracking**: Transparent view of storage costs and payments
- 📊 **Storage Analytics**: File size, storage duration, and cost analysis

## Architecture Overview

Hot Vault uses a modern full-stack architecture:

### Frontend (Next.js 14 + Wagmi)
- **React Components**: Modern UI with TypeScript
- **Wagmi Integration**: Type-safe wallet connections
- **Real-time Updates**: Live proof and payment status
- **File Management**: Upload, view, and manage stored files

### Backend (Next.js API Routes)
- **File Processing**: Handle uploads and generate CommP
- **Blockchain Integration**: Create proof sets and payment rails
- **Proof Submission**: Automated proof generation and submission
- **Payment Settlement**: Automatic payment processing

### Smart Contracts
- **PDP Verifier**: Manages proof sets and verification
- **PDP Service**: Defines storage SLA terms
- **Payments Contract**: Handles USDFC payment rails
- **Custom Arbiter**: Adjusts payments based on proof compliance

## How It Works: Complete Walkthrough

### 1. Wallet Connection (Modern Wagmi Pattern)

Hot Vault uses the latest Wagmi patterns for seamless wallet connection:

<augment_code_snippet path="hotvault-demo-source/components/WalletConnection.tsx" mode="EXCERPT">
```tsx
'use client'
import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { injected } from 'wagmi/connectors'

export function WalletConnection() {
  const { address, isConnected } = useAccount()
  const { connect } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div className="flex items-center gap-4">
        <span className="text-sm">
          {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
        <button
          onClick={() => disconnect()}
          className="px-4 py-2 bg-red-500 text-white rounded"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <button
      onClick={() => connect({ connector: injected() })}
      className="px-6 py-3 bg-blue-500 text-white rounded-lg"
    >
      Connect MetaMask
    </button>
  )
}
```
</augment_code_snippet>

### 2. File Upload with Progress Tracking

Modern drag-and-drop file upload with real-time progress:

<augment_code_snippet path="hotvault-demo-source/components/FileUpload.tsx" mode="EXCERPT">
```tsx
'use client'
import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'

export function FileUpload() {
  const [uploadProgress, setUploadProgress] = useState(0)
  const [uploading, setUploading] = useState(false)

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0]
    if (!file) return

    setUploading(true)
    setUploadProgress(0)

    const formData = new FormData()
    formData.append('file', file)

    try {
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Upload failed')

      const result = await response.json()
      console.log('Upload successful:', result)

    } catch (error) {
      console.error('Upload error:', error)
    } finally {
      setUploading(false)
      setUploadProgress(0)
    }
  }, [])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.gif'],
      'application/pdf': ['.pdf'],
    },
    maxSize: 10 * 1024 * 1024, // 10MB
  })

  return (
    <div
      {...getRootProps()}
      className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
        isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'
      }`}
    >
      <input {...getInputProps()} />
      {uploading ? (
        <div>
          <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all"
              style={{ width: `${uploadProgress}%` }}
            />
          </div>
          <p>Uploading... {uploadProgress}%</p>
        </div>
      ) : (
        <div>
          <p className="text-lg mb-2">
            {isDragActive ? 'Drop files here' : 'Drag & drop files here'}
          </p>
          <p className="text-sm text-gray-500">
            or click to select files (max 10MB)
          </p>
        </div>
      )}
    </div>
  )
}
```
</augment_code_snippet>

### 3. Next.js API Route for File Processing

Modern Next.js 14 App Router API route with proper error handling:

<augment_code_snippet path="hotvault-demo-source/app/api/upload/route.ts" mode="EXCERPT">
```typescript
import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'
import { v4 as uuidv4 } from 'uuid'
import { createCARFile, calculateCommP } from '@/lib/filecoin-utils'
import { createProofSet, createPaymentRail } from '@/lib/contracts'

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Generate unique file ID
    const fileId = uuidv4()
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)

    // Save file to storage
    const uploadDir = join(process.cwd(), 'uploads')
    await mkdir(uploadDir, { recursive: true })
    const filePath = join(uploadDir, `${fileId}-${file.name}`)
    await writeFile(filePath, buffer)

    // Generate CAR file and CommP
    const carFile = await createCARFile(buffer)
    const commP = await calculateCommP(carFile)

    // Store metadata
    const metadata = {
      fileId,
      originalName: file.name,
      size: file.size,
      mimeType: file.type,
      commP,
      uploadDate: new Date().toISOString(),
      filePath,
    }

    // TODO: Store in database
    console.log('File metadata:', metadata)

    return NextResponse.json({
      success: true,
      fileId,
      commP,
      size: file.size,
      name: file.name,
    })

  } catch (error) {
    console.error('Upload error:', error)
    return NextResponse.json(
      { error: 'Upload failed' },
      { status: 500 }
    )
  }
}
```
</augment_code_snippet>

### 4. Smart Contract Integration with Wagmi

Hot Vault uses Wagmi hooks for type-safe contract interactions:

<augment_code_snippet path="hotvault-demo-source/hooks/useContracts.ts" mode="EXCERPT">
```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther, parseUnits } from 'viem'
import { CONTRACTS } from '@/lib/contracts'

export function useCreatePaymentRail() {
  const { writeContract, data: hash, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const createRail = async (params: {
    clientAddress: string
    fileSize: number
  }) => {
    const paymentRate = calculatePaymentRate(params.fileSize)

    writeContract({
      address: CONTRACTS.PAYMENTS_ADDRESS,
      abi: CONTRACTS.PAYMENTS_ABI,
      functionName: 'createRail',
      args: [
        CONTRACTS.USDFC_TOKEN_ADDRESS, // token
        params.clientAddress,          // from
        CONTRACTS.PROVIDER_ADDRESS,    // to
        CONTRACTS.ARBITER_ADDRESS,     // arbiter
        parseUnits(paymentRate.toString(), 6), // rate (USDFC has 6 decimals)
        60n,                          // lockupPeriod (epochs)
        parseUnits('1', 6),           // lockupFixed (1 USDFC)
        0n,                           // commissionRate
      ],
    })
  }

  return {
    createRail,
    isPending: isPending || isConfirming,
    isSuccess,
    hash,
  }
}

function calculatePaymentRate(fileSize: number): number {
  // 0.01 USDFC per MB per epoch
  const sizeInMB = fileSize / (1024 * 1024)
  return Math.max(0.01, sizeInMB * 0.01)
}
```
</augment_code_snippet>

### 5. PDP Proof Set Creation

Creating proof sets with modern error handling and user feedback:

<augment_code_snippet path="hotvault-demo-source/hooks/usePDPProofSet.ts" mode="EXCERPT">
```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { encodeAbiParameters, parseEther } from 'viem'
import { CONTRACTS } from '@/lib/contracts'

export function useCreateProofSet() {
  const { writeContract, data: hash, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const createProofSet = async (params: {
    railId: bigint
    commP: string
    fileSize: number
  }) => {
    // Encode payment rail information in extra data
    const extraData = encodeAbiParameters(
      [
        { name: 'railId', type: 'uint256' },
        { name: 'paymentsContract', type: 'address' }
      ],
      [params.railId, CONTRACTS.PAYMENTS_ADDRESS]
    )

    // Get sybil fee
    const sybilFee = parseEther('0.1') // 0.1 tFIL

    writeContract({
      address: CONTRACTS.PDP_VERIFIER_ADDRESS,
      abi: CONTRACTS.PDP_VERIFIER_ABI,
      functionName: 'createProofSet',
      args: [
        CONTRACTS.PDP_SERVICE_ADDRESS,
        extraData,
      ],
      value: sybilFee,
    })
  }

  return {
    createProofSet,
    isPending: isPending || isConfirming,
    isSuccess,
    hash,
  }
}
```
</augment_code_snippet>

### 6. Real-time Storage Dashboard

Hot Vault provides a comprehensive dashboard for monitoring storage status:

<augment_code_snippet path="hotvault-demo-source/components/StorageDashboard.tsx" mode="EXCERPT">
```tsx
'use client'
import { useState, useEffect } from 'react'
import { useAccount, useReadContract } from 'wagmi'
import { CONTRACTS } from '@/lib/contracts'

interface StoredFile {
  fileId: string
  name: string
  size: number
  commP: string
  proofSetId?: bigint
  railId?: bigint
  uploadDate: string
  lastProofSubmission?: string
  proofStatus: 'pending' | 'active' | 'failed'
  paymentStatus: 'active' | 'settled' | 'disputed'
}

export function StorageDashboard() {
  const { address } = useAccount()
  const [files, setFiles] = useState<StoredFile[]>([])
  const [loading, setLoading] = useState(true)

  // Read proof set status from contract
  const { data: proofSetData } = useReadContract({
    address: CONTRACTS.PDP_VERIFIER_ADDRESS,
    abi: CONTRACTS.PDP_VERIFIER_ABI,
    functionName: 'getProofSetInfo',
    args: [1n], // Example proof set ID
  })

  useEffect(() => {
    // Load user's files from API
    const loadFiles = async () => {
      if (!address) return

      try {
        const response = await fetch(`/api/files?address=${address}`)
        const data = await response.json()
        setFiles(data.files || [])
      } catch (error) {
        console.error('Failed to load files:', error)
      } finally {
        setLoading(false)
      }
    }

    loadFiles()
  }, [address])

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500" />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Total Files</h3>
          <p className="text-3xl font-bold text-blue-600">{files.length}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Storage Used</h3>
          <p className="text-3xl font-bold text-green-600">
            {formatBytes(files.reduce((sum, f) => sum + f.size, 0))}
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-2">Active Proofs</h3>
          <p className="text-3xl font-bold text-purple-600">
            {files.filter(f => f.proofStatus === 'active').length}
          </p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b">
          <h3 className="text-lg font-semibold">Your Stored Files</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  File Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Size
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Proof Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Payment Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {files.map((file) => (
                <tr key={file.fileId}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {file.name}
                    </div>
                    <div className="text-sm text-gray-500">
                      {file.commP.slice(0, 20)}...
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatBytes(file.size)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <ProofStatusBadge status={file.proofStatus} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <PaymentStatusBadge status={file.paymentStatus} />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button className="text-blue-600 hover:text-blue-900 mr-4">
                      Download
                    </button>
                    <button className="text-red-600 hover:text-red-900">
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function ProofStatusBadge({ status }: { status: string }) {
  const colors = {
    pending: 'bg-yellow-100 text-yellow-800',
    active: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800',
  }

  return (
    <span className={`px-2 py-1 text-xs font-medium rounded-full ${colors[status as keyof typeof colors]}`}>
      {status}
    </span>
  )
}

function PaymentStatusBadge({ status }: { status: string }) {
  const colors = {
    active: 'bg-blue-100 text-blue-800',
    settled: 'bg-green-100 text-green-800',
    disputed: 'bg-red-100 text-red-800',
  }

  return (
    <span className={`px-2 py-1 text-xs font-medium rounded-full ${colors[status as keyof typeof colors]}`}>
      {status}
    </span>
  )
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
```
</augment_code_snippet>

## Running the Hot Vault Demo

### Prerequisites

- **Node.js 18+** and **npm/yarn/pnpm**
- **MetaMask** with Filecoin Calibration testnet configured
- **tFIL and USDFC tokens** (from Steps 1-2)

### 1. Clone and Setup

```bash
# Clone the Hot Vault demo
git clone https://github.com/FilOzone/hotvault-demo.git
cd hotvault-demo

# Install dependencies
npm install

# Copy environment template
cp .env.example .env.local
```

### 2. Configure Environment

Edit `.env.local` with your settings:

```bash
# Wallet Configuration
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_here

# Filecoin Calibration Network
NEXT_PUBLIC_CHAIN_ID=314159
NEXT_PUBLIC_RPC_URL=https://api.calibration.node.glif.io/rpc/v1

# Contract Addresses (Calibration Testnet)
NEXT_PUBLIC_PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
NEXT_PUBLIC_PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
NEXT_PUBLIC_PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A
NEXT_PUBLIC_USDFC_TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

# Storage Provider Configuration
NEXT_PUBLIC_PROVIDER_ADDRESS=0x742d35Cc6634C0532925a3b8D4C9db96c4b4d8b6

# Database (for production)
DATABASE_URL=postgresql://user:password@localhost:5432/hotvault
```

### 3. Start Development Server

```bash
# Start the development server
npm run dev

# Open in browser
open http://localhost:3000
```

### 4. Test the Complete Flow

1. **Connect Wallet**: Click "Connect MetaMask" and approve the connection
2. **Upload File**: Drag and drop a photo (max 10MB)
3. **Create Payment Rail**: Approve USDFC spending and create payment rail
4. **Create Proof Set**: Pay sybil fee and create proof set
5. **Monitor Storage**: View real-time proof and payment status
6. **Download File**: Retrieve your stored file anytime

## Project Structure

```
hotvault-demo/
├── app/                          # Next.js 14 App Router
│   ├── api/                      # API Routes
│   │   ├── upload/route.ts       # File upload handler
│   │   ├── files/route.ts        # File listing
│   │   └── proofs/route.ts       # Proof status
│   ├── dashboard/                # Storage dashboard
│   └── layout.tsx                # Root layout with Wagmi
├── components/                   # React Components
│   ├── WalletConnection.tsx      # Wallet connection UI
│   ├── FileUpload.tsx           # Drag & drop upload
│   ├── StorageDashboard.tsx     # File management
│   └── ProofMonitor.tsx         # Real-time proof status
├── hooks/                        # Custom Wagmi hooks
│   ├── useContracts.ts          # Contract interactions
│   ├── usePDPProofSet.ts        # PDP operations
│   └── useFileStorage.ts        # File management
├── lib/                          # Utilities
│   ├── contracts.ts             # Contract ABIs and addresses
│   ├── filecoin-utils.ts        # CAR file and CommP generation
│   └── wagmi-config.ts          # Wagmi configuration
└── public/                       # Static assets
```

## Key Features Demonstrated

### 1. Modern Web3 UX Patterns
- **Seamless Wallet Connection**: One-click MetaMask integration with Wagmi
- **Transaction Status**: Real-time feedback for all blockchain operations
- **Error Handling**: User-friendly error messages and retry mechanisms
- **Loading States**: Proper loading indicators for async operations

### 2. File Storage Workflow
- **Drag & Drop Upload**: Intuitive file selection with progress tracking
- **CommP Generation**: Automatic cryptographic proof generation
- **Metadata Management**: Comprehensive file information storage
- **Storage Provider Integration**: Automated SP selection and deal creation

### 3. Payment Management
- **Automatic Rate Calculation**: Dynamic pricing based on file size
- **USDFC Integration**: Seamless stablecoin payments
- **Payment Rails**: Automated payment streaming to storage providers
- **Settlement Tracking**: Real-time payment status monitoring

### 4. Proof Verification
- **Real-time Monitoring**: Live proof submission status
- **Compliance Tracking**: Automated SLA compliance verification
- **Proof History**: Complete audit trail of all proof submissions
- **Failure Handling**: Automatic retry and notification systems

## Technology Stack

### Frontend
- **Next.js 14**: App Router with Server Components
- **Wagmi v2**: Type-safe Ethereum interactions
- **TanStack Query**: Data fetching and caching
- **Tailwind CSS**: Utility-first styling
- **TypeScript**: Full type safety

### Backend
- **Next.js API Routes**: Serverless API endpoints
- **Prisma**: Type-safe database ORM
- **PostgreSQL**: Production database
- **IPFS**: Decentralized file storage
- **Filecoin Utils**: CAR file and CommP generation

### Smart Contracts (Pre-deployed)
- **PDP Verifier**: Deployed on Calibration testnet
- **PDP Service**: Deployed on Calibration testnet
- **Payments Contract**: Deployed on Calibration testnet
- **USDFC Token**: Deployed stablecoin contract

## Troubleshooting

### Common Issues

**Wallet Connection Fails**
- Ensure MetaMask is installed and unlocked
- Check you're on Filecoin Calibration testnet
- Disable other wallet extensions

**File Upload Errors**
- Check file size (max 10MB)
- Ensure sufficient tFIL for gas fees
- Verify network connectivity

**Transaction Failures**
- Confirm sufficient USDFC balance
- Check gas price settings
- Wait for network congestion to clear

**Proof Submission Issues**
- Verify storage provider is online
- Check proof set configuration
- Monitor network epoch timing

## Next Steps

🎉 **Congratulations!** You've completed Step 4 of the Golden Path.

**Next**: [Step 5: Photo Storage Tutorial](../first-deal.md) - Upload your first photo from desktop to storage provider

## Additional Resources

- [Hot Vault Demo Repository](https://github.com/FilOzone/hotvault-demo)
- [Wagmi Documentation](https://wagmi.sh/)
- [Next.js App Router Guide](https://nextjs.org/docs/app)
- [Filecoin Storage Documentation](https://docs.filecoin.io/storage-providers/)
- [USDFC Stablecoin Guide](https://docs.secured.finance/)
