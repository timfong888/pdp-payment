# Step 4: Hot Vault Demo Reference

This is the fourth step in your Golden Path. You'll explore the Hot Vault demo - a complete reference implementation that demonstrates how to build a modern web3 storage application using the PDP-Payments system.

**🔗 Live Demo Repository:** [https://github.com/FilOzone/hotvault-demo](https://github.com/FilOzone/hotvault-demo)

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

Hot Vault uses the latest Wagmi patterns for seamless wallet connection. The implementation demonstrates modern React patterns with TypeScript support.

**📁 Source:** [`components/WalletConnection.tsx`](https://github.com/FilOzone/hotvault-demo/blob/main/components/WalletConnection.tsx)

Key features:
- **useAccount Hook**: Manages connected wallet state
- **useConnect Hook**: Handles wallet connection with injected connector (MetaMask)
- **useDisconnect Hook**: Provides clean wallet disconnection
- **Responsive UI**: Shows connection status and wallet address truncation
- **TypeScript Support**: Full type safety with Wagmi v2

### 2. File Upload with Progress Tracking

Modern drag-and-drop file upload with real-time progress tracking and validation.

**📁 Source:** [`components/FileUpload.tsx`](https://github.com/FilOzone/hotvault-demo/blob/main/components/FileUpload.tsx)

Key features:
- **React Dropzone**: Modern drag-and-drop interface with file validation
- **Progress Tracking**: Real-time upload progress with visual indicators
- **File Validation**: Automatic file type and size validation (max 10MB)
- **Error Handling**: Comprehensive error handling with user feedback
- **FormData API**: Efficient file upload using modern browser APIs
- **Responsive Design**: Mobile-friendly upload interface

### 3. Next.js API Route for File Processing

Modern Next.js 14 App Router API route with proper error handling and Filecoin integration.

**📁 Source:** [`app/api/upload/route.ts`](https://github.com/FilOzone/hotvault-demo/blob/main/app/api/upload/route.ts)

Key features:
- **Next.js 14 App Router**: Modern API route structure with TypeScript
- **File Processing**: Handles multipart form data with proper validation
- **CAR File Generation**: Creates Content Addressable aRchive files for Filecoin
- **CommP Calculation**: Generates cryptographic proofs for file integrity
- **Error Handling**: Comprehensive error handling with proper HTTP status codes
- **Metadata Management**: Structured file metadata with unique identifiers
- **Database Integration**: Ready for database storage (currently using console logging)

### 4. Smart Contract Integration with Wagmi

Hot Vault uses Wagmi hooks for type-safe contract interactions with the PDP-Payments system.

**📁 Source:** [`hooks/useContracts.ts`](https://github.com/FilOzone/hotvault-demo/blob/main/hooks/useContracts.ts)

Key features:
- **useWriteContract Hook**: Type-safe contract function calls with Wagmi v2
- **useWaitForTransactionReceipt**: Real-time transaction confirmation tracking
- **Payment Rate Calculation**: Dynamic pricing based on file size (0.01 USDFC per MB per epoch)
- **Contract Configuration**: Pre-configured contract addresses and ABIs
- **Error Handling**: Comprehensive transaction error handling
- **TypeScript Support**: Full type safety for contract interactions
- **USDFC Integration**: Native stablecoin payment processing

### 5. PDP Proof Set Creation

Creating proof sets with modern error handling and user feedback for storage verification.

**📁 Source:** [`hooks/usePDPProofSet.ts`](https://github.com/FilOzone/hotvault-demo/blob/main/hooks/usePDPProofSet.ts)

Key features:
- **Proof Set Management**: Creates cryptographic proof sets for file storage verification
- **Payment Rail Integration**: Links proof sets to payment rails via encoded extra data
- **Sybil Fee Handling**: Automatic sybil fee calculation and payment (0.1 tFIL)
- **ABI Encoding**: Proper encoding of payment rail information for contract calls
- **Transaction Tracking**: Real-time transaction status with confirmation monitoring
- **Error Handling**: Comprehensive error handling for proof set creation failures

### 6. Real-time Storage Dashboard

Hot Vault provides a comprehensive dashboard for monitoring storage status with real-time updates.

**📁 Source:** [`components/StorageDashboard.tsx`](https://github.com/FilOzone/hotvault-demo/blob/main/components/StorageDashboard.tsx)

Key features:
- **Real-time Monitoring**: Live updates of proof submission and payment status
- **File Management**: Complete file listing with metadata and actions
- **Status Indicators**: Visual badges for proof and payment status
- **Storage Analytics**: Total files, storage used, and active proofs metrics
- **Contract Integration**: Direct contract reads for proof set information
- **Responsive Design**: Mobile-friendly table layout with overflow handling
- **TypeScript Interfaces**: Strongly typed file and status data structures

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

## Production Deployment with Vercel

### Overview

Deploy your Hot Vault application to production using Vercel's modern deployment platform. This section covers the complete deployment process, environment configuration, and CI/CD setup.

### Prerequisites for Production

- **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
- **GitHub Repository**: Your Hot Vault fork or clone
- **Environment Variables**: Production contract addresses and API keys
- **Domain (Optional)**: Custom domain for your application

### Step 1: Prepare for Deployment

1. **Fork the Repository**
   ```bash
   # Fork the Hot Vault demo repository
   git clone https://github.com/YOUR_USERNAME/hotvault-demo.git
   cd hotvault-demo
   ```

2. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   vercel login
   ```

3. **Configure Environment Variables**

   Create a `.env.production` file:
   ```bash
   # Production Environment Variables
   NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_production_project_id
   NEXT_PUBLIC_CHAIN_ID=314159
   NEXT_PUBLIC_RPC_URL=https://api.calibration.node.glif.io/rpc/v1

   # Production Contract Addresses
   NEXT_PUBLIC_PDP_VERIFIER_ADDRESS=0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC
   NEXT_PUBLIC_PDP_SERVICE_ADDRESS=0x6170dE2b09b404776197485F3dc6c968Ef948505
   NEXT_PUBLIC_PAYMENTS_ADDRESS=0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A
   NEXT_PUBLIC_USDFC_TOKEN_ADDRESS=0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0

   # Database (Production)
   DATABASE_URL=postgresql://user:password@host:5432/hotvault_prod

   # Storage Configuration
   STORAGE_PROVIDER_ENDPOINT=https://your-storage-provider.com
   IPFS_GATEWAY=https://your-ipfs-gateway.com
   ```

### Step 2: Deploy to Vercel

1. **Connect Repository**
   ```bash
   vercel --prod
   ```

2. **Configure Project Settings**
   - **Framework Preset**: Next.js
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm install`

3. **Set Environment Variables**
   ```bash
   # Set production environment variables
   vercel env add NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID production
   vercel env add NEXT_PUBLIC_CHAIN_ID production
   vercel env add DATABASE_URL production
   # ... add all other environment variables
   ```

### Step 3: Configure CI/CD Pipeline

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build application
        run: npm run build

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

### Step 4: Production Best Practices

1. **Security Configuration**
   - Enable HTTPS redirects
   - Configure CORS policies
   - Set up rate limiting
   - Implement proper error handling

2. **Performance Optimization**
   - Enable Vercel Edge Functions for API routes
   - Configure CDN caching for static assets
   - Implement image optimization
   - Use Vercel Analytics for monitoring

3. **Monitoring and Logging**
   - Set up Vercel Analytics
   - Configure error tracking (Sentry)
   - Implement health checks
   - Monitor contract interactions

### Step 5: Custom Domain Setup

1. **Add Custom Domain**
   ```bash
   vercel domains add yourdomain.com
   ```

2. **Configure DNS**
   - Add CNAME record pointing to `cname.vercel-dns.com`
   - Or add A record pointing to Vercel's IP addresses

3. **SSL Certificate**
   - Vercel automatically provisions SSL certificates
   - Certificates auto-renew every 90 days

### Deployment Hooks Integration

Configure deployment hooks for automated deployments:

```typescript
// vercel.json
{
  "functions": {
    "app/api/**/*.ts": {
      "runtime": "@vercel/node"
    }
  },
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "/api/$1"
    }
  ],
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
        }
      ]
    }
  ]
}
```

### Troubleshooting Production Issues

**Common Deployment Issues:**

1. **Environment Variables Not Loading**
   - Verify all environment variables are set in Vercel dashboard
   - Check variable names match exactly (case-sensitive)
   - Ensure `NEXT_PUBLIC_` prefix for client-side variables

2. **Contract Connection Failures**
   - Verify contract addresses are correct for target network
   - Check RPC endpoint is accessible and has sufficient rate limits
   - Ensure wallet connection works with production domain

3. **Build Failures**
   - Check Node.js version compatibility
   - Verify all dependencies are listed in package.json
   - Review build logs for specific error messages

## Additional Resources

- [Hot Vault Demo Repository](https://github.com/FilOzone/hotvault-demo)
- [Vercel Deployment Documentation](https://vercel.com/docs/deployments)
- [Wagmi Documentation](https://wagmi.sh/)
- [Next.js App Router Guide](https://nextjs.org/docs/app)
- [Filecoin Storage Documentation](https://docs.filecoin.io/storage-providers/)
- [USDFC Stablecoin Guide](https://docs.secured.finance/)
- [Vercel Environment Variables Guide](https://vercel.com/docs/projects/environment-variables)
