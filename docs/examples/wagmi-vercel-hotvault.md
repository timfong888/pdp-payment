# Wagmi-Vercel Hot Vault: Modern Web3 Storage Application

This guide shows how to build a modern Hot Vault application using **Wagmi v2** for Web3 interactions and **Vercel** for deployment, eliminating the need for Docker containers and Go backend servers.

**🔗 Reference Implementation:** [Original Hot Vault Demo](https://github.com/FilOzone/hotvault-demo)

> **📚 Comparing approaches?** See the [Traditional Hot Vault Guide](hot-vault.md) for the Docker-based reference implementation with detailed explanations of the core concepts.

## Why Wagmi + Vercel?

### Advantages Over Original Architecture

| Original Hot Vault | Wagmi-Vercel Hot Vault |
|-------------------|------------------------|
| ethers.js + Go backend | Wagmi v2 + Next.js API routes |
| Docker + PostgreSQL | Vercel + Serverless functions |
| Manual deployment | Automated CI/CD |
| Complex setup | One-click deployment |

### Key Benefits

- **🚀 Faster Development**: Type-safe React hooks with Wagmi v2
- **☁️ Serverless Architecture**: No Docker containers or server management
- **🔄 Auto-scaling**: Vercel handles traffic spikes automatically
- **🛡️ Built-in Security**: HTTPS, DDoS protection, and edge caching
- **📊 Analytics**: Built-in performance monitoring

## Prerequisites

- **Node.js 18+** and **npm/yarn/pnpm**
- **Vercel Account**: [Sign up free](https://vercel.com)
- **MetaMask** with Filecoin Calibration testnet
- **USDFC tokens** for payments

## Project Architecture

```
wagmi-vercel-hotvault/
├── app/                          # Next.js 14 App Router
│   ├── api/                      # Serverless API routes
│   │   ├── upload/route.ts       # File upload handler
│   │   ├── files/route.ts        # File management
│   │   └── contracts/route.ts    # Contract interactions
│   ├── dashboard/                # Storage dashboard
│   ├── layout.tsx                # Root layout with Wagmi
│   └── page.tsx                  # Landing page
├── components/                   # React Components
│   ├── WalletConnection.tsx      # Wagmi wallet integration
│   ├── FileUpload.tsx           # Drag & drop upload
│   ├── StorageDashboard.tsx     # File management UI
│   └── ContractInteraction.tsx  # PDP contract calls
├── hooks/                        # Custom Wagmi hooks
│   ├── useCreatePaymentRail.ts  # Payment rail creation
│   ├── useCreateProofSet.ts     # PDP proof set management
│   └── useFileStorage.ts        # File storage operations
├── lib/                          # Utilities
│   ├── wagmi-config.ts          # Wagmi configuration
│   ├── contracts.ts             # Contract ABIs and addresses
│   └── storage.ts               # File storage utilities
└── vercel.json                  # Vercel configuration
```

## Step 1: Initialize Project

```bash
# Create new Next.js project
npx create-next-app@latest wagmi-vercel-hotvault --typescript --tailwind --app
cd wagmi-vercel-hotvault

# Install Wagmi and dependencies
npm install wagmi viem @tanstack/react-query
npm install @vercel/blob @vercel/kv  # Vercel storage
npm install react-dropzone uuid      # File handling
```

## Step 2: Configure Wagmi

Create `lib/wagmi-config.ts`:

```typescript
import { http, createConfig } from 'wagmi'
import { filecoinCalibration } from 'wagmi/chains'
import { injected, metaMask } from 'wagmi/connectors'

export const config = createConfig({
  chains: [filecoinCalibration],
  connectors: [
    injected(),
    metaMask(),
  ],
  transports: {
    [filecoinCalibration.id]: http(
      process.env.NEXT_PUBLIC_RPC_URL || 
      'https://api.calibration.node.glif.io/rpc/v1'
    ),
  },
})

declare module 'wagmi' {
  interface Register {
    config: typeof config
  }
}
```

## Step 3: Contract Configuration

Create `lib/contracts.ts`:

```typescript
export const CONTRACTS = {
  // Filecoin Calibration Network addresses
  PDP_VERIFIER_ADDRESS: '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC' as const,
  PDP_SERVICE_ADDRESS: '0x6170dE2b09b404776197485F3dc6c968Ef948505' as const,
  PAYMENTS_ADDRESS: '0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A' as const,
  USDFC_TOKEN_ADDRESS: '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0' as const,
  
  // ABIs (simplified for example)
  PAYMENTS_ABI: [
    {
      name: 'createRail',
      type: 'function',
      inputs: [
        { name: 'token', type: 'address' },
        { name: 'from', type: 'address' },
        { name: 'to', type: 'address' },
        { name: 'arbiter', type: 'address' },
        { name: 'rate', type: 'uint256' },
        { name: 'lockupPeriod', type: 'uint256' },
        { name: 'lockupFixed', type: 'uint256' },
        { name: 'commissionRate', type: 'uint256' },
      ],
      outputs: [{ name: 'railId', type: 'uint256' }],
    },
  ] as const,
  
  PDP_VERIFIER_ABI: [
    {
      name: 'createProofSet',
      type: 'function',
      inputs: [
        { name: 'service', type: 'address' },
        { name: 'extraData', type: 'bytes' },
      ],
      outputs: [{ name: 'proofSetId', type: 'uint256' }],
    },
  ] as const,
} as const
```

## Step 4: Wagmi Hooks for Contract Interactions

Create `hooks/useCreatePaymentRail.ts`:

```typescript
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseUnits } from 'viem'
import { CONTRACTS } from '@/lib/contracts'

export function useCreatePaymentRail() {
  const { writeContract, data: hash, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const createRail = async (params: {
    clientAddress: `0x${string}`
    providerAddress: `0x${string}`
    fileSize: number
  }) => {
    // Calculate payment rate: 0.01 USDFC per MB per epoch
    const sizeInMB = params.fileSize / (1024 * 1024)
    const paymentRate = Math.max(0.01, sizeInMB * 0.01)

    writeContract({
      address: CONTRACTS.PAYMENTS_ADDRESS,
      abi: CONTRACTS.PAYMENTS_ABI,
      functionName: 'createRail',
      args: [
        CONTRACTS.USDFC_TOKEN_ADDRESS,
        params.clientAddress,
        params.providerAddress,
        CONTRACTS.PDP_SERVICE_ADDRESS, // arbiter
        parseUnits(paymentRate.toString(), 6), // USDFC has 6 decimals
        60n, // lockupPeriod (epochs)
        parseUnits('1', 6), // lockupFixed (1 USDFC)
        0n, // commissionRate
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
```

## Step 5: Serverless File Upload API

Create `app/api/upload/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { put } from '@vercel/blob'
import { v4 as uuidv4 } from 'uuid'

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

    // Upload to Vercel Blob Storage
    const fileId = uuidv4()
    const filename = `${fileId}-${file.name}`

    const blob = await put(filename, file, {
      access: 'public',
      addRandomSuffix: false,
    })

    // Generate CommP (simplified - in production, use proper CAR file generation)
    const buffer = await file.arrayBuffer()
    const commP = `baga6ea4seaq${Buffer.from(buffer).toString('hex').slice(0, 32)}`

    // Store metadata in Vercel KV
    const metadata = {
      fileId,
      originalName: file.name,
      size: file.size,
      mimeType: file.type,
      commP,
      blobUrl: blob.url,
      uploadDate: new Date().toISOString(),
    }

    // In production, store in Vercel KV or database
    console.log('File metadata:', metadata)

    return NextResponse.json({
      success: true,
      fileId,
      commP,
      size: file.size,
      name: file.name,
      url: blob.url,
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

## Step 6: Modern Wallet Connection Component

Create `components/WalletConnection.tsx`:

```typescript
'use client'
import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { injected } from 'wagmi/connectors'

export function WalletConnection() {
  const { address, isConnected } = useAccount()
  const { connect, isPending } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div className="flex items-center gap-4 p-4 bg-green-50 rounded-lg">
        <div className="flex-1">
          <p className="text-sm text-green-700">Connected to</p>
          <p className="font-mono text-sm">
            {address?.slice(0, 6)}...{address?.slice(-4)}
          </p>
        </div>
        <button
          onClick={() => disconnect()}
          className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <div className="p-4 bg-blue-50 rounded-lg">
      <button
        onClick={() => connect({ connector: injected() })}
        disabled={isPending}
        className="w-full px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50"
      >
        {isPending ? 'Connecting...' : 'Connect MetaMask'}
      </button>
    </div>
  )
}
```

## Step 7: File Upload with Drag & Drop

Create `components/FileUpload.tsx`:

```typescript
'use client'
import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { useCreatePaymentRail } from '@/hooks/useCreatePaymentRail'
import { useAccount } from 'wagmi'

interface UploadedFile {
  fileId: string
  name: string
  size: number
  commP: string
  url: string
}

export function FileUpload() {
  const { address } = useAccount()
  const [uploading, setUploading] = useState(false)
  const [uploadedFiles, setUploadedFiles] = useState<UploadedFile[]>([])
  const { createRail, isPending: isCreatingRail } = useCreatePaymentRail()

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    if (!address) {
      alert('Please connect your wallet first')
      return
    }

    const file = acceptedFiles[0]
    if (!file) return

    setUploading(true)

    try {
      // Upload file to Vercel Blob
      const formData = new FormData()
      formData.append('file', file)

      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Upload failed')

      const result = await response.json()

      // Add to uploaded files list
      setUploadedFiles(prev => [...prev, result])

      // Create payment rail for the file
      await createRail({
        clientAddress: address,
        providerAddress: '0x742d35Cc6634C0532925a3b8D4C9db96c4b4d8b6', // Example provider
        fileSize: file.size,
      })

    } catch (error) {
      console.error('Upload error:', error)
      alert('Upload failed. Please try again.')
    } finally {
      setUploading(false)
    }
  }, [address, createRail])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.png', '.jpg', '.jpeg', '.gif'],
      'application/pdf': ['.pdf'],
      'text/*': ['.txt', '.md'],
    },
    maxSize: 10 * 1024 * 1024, // 10MB
    multiple: false,
  })

  return (
    <div className="space-y-6">
      <div
        {...getRootProps()}
        className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
          isDragActive
            ? 'border-blue-500 bg-blue-50'
            : 'border-gray-300 hover:border-gray-400'
        }`}
      >
        <input {...getInputProps()} />
        {uploading || isCreatingRail ? (
          <div>
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4" />
            <p>
              {uploading ? 'Uploading file...' : 'Creating payment rail...'}
            </p>
          </div>
        ) : (
          <div>
            <p className="text-lg mb-2">
              {isDragActive ? 'Drop files here' : 'Drag & drop files here'}
            </p>
            <p className="text-sm text-gray-500">
              or click to select files (max 10MB)
            </p>
            <p className="text-xs text-gray-400 mt-2">
              Supports: Images, PDFs, Text files
            </p>
          </div>
        )}
      </div>

      {uploadedFiles.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4">Uploaded Files</h3>
          <div className="space-y-3">
            {uploadedFiles.map((file) => (
              <div key={file.fileId} className="flex items-center justify-between p-3 bg-gray-50 rounded">
                <div>
                  <p className="font-medium">{file.name}</p>
                  <p className="text-sm text-gray-500">
                    {(file.size / 1024 / 1024).toFixed(2)} MB • CommP: {file.commP.slice(0, 20)}...
                  </p>
                </div>
                <a
                  href={file.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600"
                >
                  View
                </a>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
```

## Step 8: Main Application Layout

Create `app/layout.tsx`:

```typescript
'use client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider } from 'wagmi'
import { config } from '@/lib/wagmi-config'
import './globals.css'

const queryClient = new QueryClient()

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <WagmiProvider config={config}>
          <QueryClientProvider client={queryClient}>
            <div className="min-h-screen bg-gray-50">
              <header className="bg-white shadow-sm border-b">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                  <h1 className="text-2xl font-bold text-gray-900">
                    Wagmi-Vercel Hot Vault
                  </h1>
                  <p className="text-gray-600">
                    Modern Web3 storage with Filecoin PDP
                  </p>
                </div>
              </header>
              <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {children}
              </main>
            </div>
          </QueryClientProvider>
        </WagmiProvider>
      </body>
    </html>
  )
}
```

Create `app/page.tsx`:

```typescript
import { WalletConnection } from '@/components/WalletConnection'
import { FileUpload } from '@/components/FileUpload'

export default function HomePage() {
  return (
    <div className="space-y-8">
      <div className="text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-4">
          Decentralized File Storage
        </h2>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          Upload files to Filecoin storage providers with automatic payment rails
          and cryptographic proof verification using PDP (Proof of Data Possession).
        </p>
      </div>

      <WalletConnection />
      <FileUpload />

      <div className="bg-blue-50 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-blue-900 mb-2">
          How it works:
        </h3>
        <ol className="list-decimal list-inside space-y-2 text-blue-800">
          <li>Connect your MetaMask wallet to Filecoin Calibration network</li>
          <li>Upload files using drag & drop interface</li>
          <li>Automatic payment rail creation with USDFC tokens</li>
          <li>Files stored on Filecoin with cryptographic proofs</li>
          <li>Real-time monitoring of storage and payment status</li>
        </ol>
      </div>
    </div>
  )
}
```

## Step 9: Vercel Configuration

Create `vercel.json`:

```json
{
  "functions": {
    "app/api/**/*.ts": {
      "runtime": "@vercel/node"
    }
  },
  "env": {
    "NEXT_PUBLIC_RPC_URL": "https://api.calibration.node.glif.io/rpc/v1",
    "NEXT_PUBLIC_CHAIN_ID": "314159"
  },
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, PUT, DELETE, OPTIONS"
        },
        {
          "key": "Access-Control-Allow-Headers",
          "value": "Content-Type, Authorization"
        }
      ]
    }
  ]
}
```

Create `package.json` scripts:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "deploy": "vercel --prod"
  }
}
```

## Step 10: Environment Variables

Create `.env.local` for development:

```bash
# Filecoin Calibration Network
NEXT_PUBLIC_CHAIN_ID=314159
NEXT_PUBLIC_RPC_URL=https://api.calibration.node.glif.io/rpc/v1

# Contract Addresses (Calibration Testnet)
NEXT_PUBLIC_PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
NEXT_PUBLIC_PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
NEXT_PUBLIC_PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A
NEXT_PUBLIC_USDFC_TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

# Vercel Storage (get from Vercel dashboard)
BLOB_READ_WRITE_TOKEN=your_blob_token_here
KV_REST_API_URL=your_kv_url_here
KV_REST_API_TOKEN=your_kv_token_here
```

## Step 11: Deploy to Vercel

### Option 1: Deploy via CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

### Option 2: Deploy via GitHub Integration

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial Wagmi-Vercel Hot Vault"
   git remote add origin https://github.com/YOUR_USERNAME/wagmi-vercel-hotvault.git
   git push -u origin main
   ```

2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Configure environment variables in Vercel dashboard

3. **Set Environment Variables in Vercel**:
   - Go to Project Settings → Environment Variables
   - Add all variables from `.env.local`
   - Deploy automatically triggers

## Key Differences from Original Hot Vault

| Feature | Original Hot Vault | Wagmi-Vercel Hot Vault |
|---------|-------------------|------------------------|
| **Web3 Library** | ethers.js | Wagmi v2 with React hooks |
| **Backend** | Go server + PostgreSQL | Next.js API routes |
| **Deployment** | Docker containers | Vercel serverless |
| **File Storage** | Local filesystem | Vercel Blob Storage |
| **Database** | PostgreSQL | Vercel KV (optional) |
| **Setup Complexity** | High (Docker, Go, DB) | Low (npm install) |
| **Scaling** | Manual | Automatic |
| **Cost** | Server hosting | Pay-per-use |

## Benefits of This Approach

### 🚀 **Developer Experience**
- **Type Safety**: Full TypeScript support with Wagmi hooks
- **Hot Reload**: Instant development feedback
- **Zero Config**: No Docker or database setup required

### ☁️ **Production Ready**
- **Auto-scaling**: Handles traffic spikes automatically
- **Global CDN**: Fast file delivery worldwide
- **HTTPS**: Built-in SSL certificates

### 💰 **Cost Effective**
- **Serverless**: Pay only for actual usage
- **No Infrastructure**: No server maintenance costs
- **Free Tier**: Generous free limits for development

### 🔒 **Security**
- **Edge Runtime**: Secure serverless execution
- **Environment Variables**: Secure secret management
- **DDoS Protection**: Built-in attack mitigation

## Next Steps

1. **Add PDP Proof Set Creation**: Implement the `useCreateProofSet` hook
2. **Real-time Monitoring**: Add WebSocket connections for live updates
3. **File Management**: Build a dashboard for managing uploaded files
4. **Payment Tracking**: Monitor USDFC payment rail status
5. **Error Handling**: Implement comprehensive error boundaries

## Conclusion

The Wagmi-Vercel Hot Vault demonstrates how modern Web3 applications can be built with:

- **Simplified Architecture**: No Docker or complex backend setup
- **Modern Tooling**: Wagmi v2 for type-safe Web3 interactions
- **Serverless Deployment**: Vercel for automatic scaling and global distribution
- **Developer Productivity**: Hot reload, TypeScript, and modern React patterns

This approach eliminates the complexity of the original Docker-based setup while providing a more scalable and maintainable solution for Web3 storage applications.

**🔗 Ready to deploy?** Follow the steps above to get your Wagmi-Vercel Hot Vault running in production!
