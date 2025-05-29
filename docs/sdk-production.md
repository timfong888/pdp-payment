# Step 5: Production Deployment

This is the final step in your Developer Path - learn how to deploy PDP-Payments applications to production with security, scalability, and reliability.

## Prerequisites

- ✅ **Completed [Step 4: Monitor & Verify](sdk-monitoring.md)** - You understand monitoring and verification
- ✅ **Production environment** ready for deployment

## 🎯 Production Readiness Checklist

### 🔒 **Security**
- [ ] Private keys stored securely (not in code)
- [ ] Environment variables properly configured
- [ ] Network access restricted appropriately
- [ ] Monitoring and alerting in place

### 📈 **Scalability**
- [ ] Connection pooling implemented
- [ ] Rate limiting configured
- [ ] Error handling and retries
- [ ] Load balancing for high availability

### 💰 **Financial Management**
- [ ] USDFC balance monitoring
- [ ] Automatic top-up strategies
- [ ] Payment settlement tracking
- [ ] Cost optimization

## 1. Secure Configuration

### Environment Variables
Create a production `.env` file:

```bash
# .env.production
# Never commit this file!

# Wallet Configuration
PRIVATE_KEY=your_production_private_key_here
WALLET_ADDRESS=0x1234567890123456789012345678901234567890

# Network Configuration
RPC_URL=https://api.calibration.node.glif.io/rpc/v1
NETWORK_ID=314159

# SDK Configuration
SYNAPSE_WITH_CDN=true
SYNAPSE_SERVICE_CONTRACT=0x...
SYNAPSE_SUBGRAPH_API=https://...

# Monitoring
BALANCE_THRESHOLD=50
ALERT_WEBHOOK_URL=https://your-monitoring-service.com/webhook
LOG_LEVEL=info

# Rate Limiting
MAX_UPLOADS_PER_MINUTE=10
MAX_CONCURRENT_OPERATIONS=5
```

### Secure Key Management
```javascript
// production-config.js
import { readFileSync } from 'fs'

class ProductionConfig {
  constructor() {
    this.validateEnvironment()
  }
  
  validateEnvironment() {
    const required = [
      'PRIVATE_KEY',
      'WALLET_ADDRESS', 
      'RPC_URL',
      'BALANCE_THRESHOLD'
    ]
    
    for (const key of required) {
      if (!process.env[key]) {
        throw new Error(`Missing required environment variable: ${key}`)
      }
    }
  }
  
  getSynapseConfig() {
    return {
      privateKey: process.env.PRIVATE_KEY,
      withCDN: process.env.SYNAPSE_WITH_CDN === 'true',
      rpcAPI: process.env.RPC_URL,
      serviceContract: process.env.SYNAPSE_SERVICE_CONTRACT,
      subgraphAPI: process.env.SYNAPSE_SUBGRAPH_API,
    }
  }
  
  getMonitoringConfig() {
    return {
      balanceThreshold: parseFloat(process.env.BALANCE_THRESHOLD),
      alertWebhook: process.env.ALERT_WEBHOOK_URL,
      logLevel: process.env.LOG_LEVEL || 'info',
    }
  }
  
  getRateLimits() {
    return {
      maxUploadsPerMinute: parseInt(process.env.MAX_UPLOADS_PER_MINUTE) || 10,
      maxConcurrentOps: parseInt(process.env.MAX_CONCURRENT_OPERATIONS) || 5,
    }
  }
}

export default new ProductionConfig()
```

## 2. Production-Ready SDK Wrapper

```javascript
// production-synapse.js
import { Synapse } from 'synapse-sdk'
import config from './production-config.js'

class ProductionSynapse {
  constructor() {
    this.synapse = new Synapse(config.getSynapseConfig())
    this.storage = null
    this.rateLimiter = new Map() // Simple rate limiting
    this.operationQueue = []
    this.activeOperations = 0
    this.maxConcurrent = config.getRateLimits().maxConcurrentOps
  }
  
  async initialize() {
    console.log('🏭 Initializing Production Synapse...')
    
    // Test connection
    await this.healthCheck()
    
    // Initialize storage service
    this.storage = await this.synapse.createStorage()
    
    // Start monitoring
    this.startMonitoring()
    
    console.log('✅ Production Synapse ready')
    return this
  }
  
  async healthCheck() {
    try {
      const balance = await this.synapse.balance()
      console.log(`💰 Current balance: ${balance} USDFC`)
      
      if (balance < config.getMonitoringConfig().balanceThreshold) {
        await this.alertLowBalance(balance)
      }
      
      return { status: 'healthy', balance }
    } catch (error) {
      console.error('❌ Health check failed:', error.message)
      throw new Error(`Health check failed: ${error.message}`)
    }
  }
  
  async storeFileWithRetry(data, options = {}) {
    const maxRetries = options.maxRetries || 3
    const retryDelay = options.retryDelay || 1000
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check rate limits
        await this.checkRateLimit()
        
        // Queue operation if at capacity
        await this.queueOperation()
        
        console.log(`📤 Upload attempt ${attempt}/${maxRetries}`)
        
        const uploadTask = this.storage.upload(data)
        const commp = await uploadTask.commp()
        const sp = await uploadTask.store()
        const txHash = await uploadTask.done()
        
        this.completeOperation()
        
        return { commp, storageProvider: sp, txHash }
        
      } catch (error) {
        console.error(`❌ Upload attempt ${attempt} failed:`, error.message)
        
        if (attempt === maxRetries) {
          this.completeOperation()
          throw error
        }
        
        // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, retryDelay * attempt))
      }
    }
  }
  
  async checkRateLimit() {
    const now = Date.now()
    const windowStart = now - 60000 // 1 minute window
    const limits = config.getRateLimits()
    
    // Clean old entries
    for (const [timestamp] of this.rateLimiter) {
      if (timestamp < windowStart) {
        this.rateLimiter.delete(timestamp)
      }
    }
    
    if (this.rateLimiter.size >= limits.maxUploadsPerMinute) {
      throw new Error('Rate limit exceeded. Please try again later.')
    }
    
    this.rateLimiter.set(now, true)
  }
  
  async queueOperation() {
    return new Promise((resolve) => {
      if (this.activeOperations < this.maxConcurrent) {
        this.activeOperations++
        resolve()
      } else {
        this.operationQueue.push(resolve)
      }
    })
  }
  
  completeOperation() {
    this.activeOperations--
    if (this.operationQueue.length > 0) {
      const next = this.operationQueue.shift()
      this.activeOperations++
      next()
    }
  }
  
  startMonitoring() {
    // Monitor balance every 5 minutes
    setInterval(async () => {
      try {
        await this.healthCheck()
      } catch (error) {
        console.error('🚨 Monitoring error:', error.message)
        await this.alertSystemError(error)
      }
    }, 5 * 60 * 1000)
    
    // Settle payments every hour
    setInterval(async () => {
      try {
        const settlement = await this.storage.settlePayments()
        console.log(`💸 Auto-settlement: ${settlement.settledAmount} USDFC`)
      } catch (error) {
        console.error('❌ Settlement error:', error.message)
      }
    }, 60 * 60 * 1000)
  }
  
  async alertLowBalance(balance) {
    const message = `🚨 Low balance alert: ${balance} USDFC remaining`
    console.warn(message)
    
    if (config.getMonitoringConfig().alertWebhook) {
      try {
        await fetch(config.getMonitoringConfig().alertWebhook, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            alert: 'low_balance',
            balance,
            threshold: config.getMonitoringConfig().balanceThreshold,
            timestamp: new Date().toISOString()
          })
        })
      } catch (error) {
        console.error('Failed to send alert:', error.message)
      }
    }
  }
  
  async alertSystemError(error) {
    const message = `🚨 System error: ${error.message}`
    console.error(message)
    
    if (config.getMonitoringConfig().alertWebhook) {
      try {
        await fetch(config.getMonitoringConfig().alertWebhook, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            alert: 'system_error',
            error: error.message,
            stack: error.stack,
            timestamp: new Date().toISOString()
          })
        })
      } catch (alertError) {
        console.error('Failed to send error alert:', alertError.message)
      }
    }
  }
}

export default ProductionSynapse
```

## 3. React + Next.js Integration

### Create Next.js App with PDP-Payments

```bash
# Create Next.js app (recommended approach)
npx create-next-app@latest my-pdp-app --typescript --tailwind --eslint --app
cd my-pdp-app

# Install Synapse SDK
npm install synapse-sdk

# Install additional dependencies for file handling
npm install react-dropzone
```

### React Hook for Synapse SDK

```typescript
// hooks/useSynapse.ts
import { useState, useEffect } from 'react'
import { Synapse } from 'synapse-sdk'

interface SynapseState {
  synapse: Synapse | null
  storage: any | null
  balance: number
  loading: boolean
  error: string | null
}

export function useSynapse(privateKey: string) {
  const [state, setState] = useState<SynapseState>({
    synapse: null,
    storage: null,
    balance: 0,
    loading: true,
    error: null
  })

  useEffect(() => {
    async function initializeSynapse() {
      try {
        const synapse = new Synapse({
          privateKey,
          withCDN: true,
        })

        const balance = await synapse.balance()
        const storage = await synapse.createStorage()

        setState({
          synapse,
          storage,
          balance,
          loading: false,
          error: null
        })
      } catch (error) {
        setState(prev => ({
          ...prev,
          loading: false,
          error: error instanceof Error ? error.message : 'Unknown error'
        }))
      }
    }

    if (privateKey) {
      initializeSynapse()
    }
  }, [privateKey])

  return state
}
```

### File Upload Component

```typescript
// components/FileUploader.tsx
'use client'

import { useState } from 'react'
import { useDropzone } from 'react-dropzone'
import { useSynapse } from '@/hooks/useSynapse'

interface UploadedFile {
  commp: string
  filename: string
  size: number
  txHash: string
  uploadTime: Date
}

export default function FileUploader() {
  const [privateKey, setPrivateKey] = useState('')
  const [uploadedFiles, setUploadedFiles] = useState<UploadedFile[]>([])
  const [uploading, setUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState('')

  const { synapse, storage, balance, loading, error } = useSynapse(privateKey)

  const onDrop = async (acceptedFiles: File[]) => {
    if (!storage) return

    setUploading(true)

    for (const file of acceptedFiles) {
      try {
        setUploadProgress(`Uploading ${file.name}...`)

        // Convert file to Uint8Array
        const arrayBuffer = await file.arrayBuffer()
        const data = new Uint8Array(arrayBuffer)

        // Upload with progress tracking
        const uploadTask = storage.upload(data)

        setUploadProgress(`Generating CommP for ${file.name}...`)
        const commp = await uploadTask.commp()

        setUploadProgress(`Storing ${file.name} with provider...`)
        const sp = await uploadTask.store()

        setUploadProgress(`Committing ${file.name} to blockchain...`)
        const txHash = await uploadTask.done()

        // Add to uploaded files list
        const uploadedFile: UploadedFile = {
          commp: commp.toString(),
          filename: file.name,
          size: file.size,
          txHash,
          uploadTime: new Date()
        }

        setUploadedFiles(prev => [...prev, uploadedFile])

      } catch (error) {
        console.error(`Upload failed for ${file.name}:`, error)
        alert(`Upload failed for ${file.name}: ${error}`)
      }
    }

    setUploading(false)
    setUploadProgress('')
  }

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    disabled: !storage || uploading
  })

  const downloadFile = async (commp: string, filename: string) => {
    if (!storage) return

    try {
      const data = await storage.download(commp, {
        noVerify: false,
        withCDN: true
      })

      // Create download link
      const blob = new Blob([data])
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)

    } catch (error) {
      console.error('Download failed:', error)
      alert(`Download failed: ${error}`)
    }
  }

  if (loading) {
    return <div className="p-8">Loading Synapse SDK...</div>
  }

  if (error) {
    return <div className="p-8 text-red-600">Error: {error}</div>
  }

  return (
    <div className="max-w-4xl mx-auto p-8">
      <h1 className="text-3xl font-bold mb-8">PDP-Payments File Storage</h1>

      {/* Private Key Input */}
      {!synapse && (
        <div className="mb-8">
          <label className="block text-sm font-medium mb-2">
            Private Key (without 0x prefix):
          </label>
          <input
            type="password"
            value={privateKey}
            onChange={(e) => setPrivateKey(e.target.value)}
            className="w-full p-3 border rounded-lg"
            placeholder="Enter your private key..."
          />
        </div>
      )}

      {synapse && (
        <>
          {/* Balance Display */}
          <div className="mb-8 p-4 bg-blue-50 rounded-lg">
            <h2 className="text-lg font-semibold">Account Status</h2>
            <p>Balance: {balance} USDFC</p>
            {balance < 10 && (
              <p className="text-orange-600">⚠️ Low balance - consider depositing more USDFC</p>
            )}
          </div>

          {/* File Upload Area */}
          <div
            {...getRootProps()}
            className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
              isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'
            } ${uploading ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            <input {...getInputProps()} />
            {uploading ? (
              <div>
                <p className="text-lg">Uploading...</p>
                <p className="text-sm text-gray-600">{uploadProgress}</p>
              </div>
            ) : isDragActive ? (
              <p className="text-lg">Drop files here...</p>
            ) : (
              <div>
                <p className="text-lg">Drag & drop files here, or click to select</p>
                <p className="text-sm text-gray-600">Files will be stored with PDP verification and automatic payments</p>
              </div>
            )}
          </div>

          {/* Uploaded Files List */}
          {uploadedFiles.length > 0 && (
            <div className="mt-8">
              <h2 className="text-xl font-semibold mb-4">Uploaded Files</h2>
              <div className="space-y-4">
                {uploadedFiles.map((file, index) => (
                  <div key={index} className="border rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-medium">{file.filename}</h3>
                        <p className="text-sm text-gray-600">Size: {file.size} bytes</p>
                        <p className="text-sm text-gray-600">
                          CommP: {file.commp.substring(0, 20)}...
                        </p>
                        <p className="text-sm text-gray-600">
                          Uploaded: {file.uploadTime.toLocaleString()}
                        </p>
                      </div>
                      <button
                        onClick={() => downloadFile(file.commp, file.filename)}
                        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                      >
                        Download
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  )
}
```

## 4. Vercel Deployment (Recommended)

### Main App Page

```typescript
// app/page.tsx
import FileUploader from '@/components/FileUploader'

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50">
      <FileUploader />
    </main>
  )
}
```

### Environment Variables Setup

```bash
# .env.local (for development)
NEXT_PUBLIC_PRIVATE_KEY=your_private_key_here

# For production, set in Vercel dashboard:
# Settings > Environment Variables
```

### Optional: API Route for Server-Side Operations

```typescript
// app/api/balance/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { Synapse } from 'synapse-sdk'

export async function GET(request: NextRequest) {
  try {
    const privateKey = process.env.PRIVATE_KEY
    if (!privateKey) {
      return NextResponse.json({ error: 'Private key not configured' }, { status: 500 })
    }

    const synapse = new Synapse({ privateKey, withCDN: true })
    const balance = await synapse.balance()

    return NextResponse.json({ balance })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch balance' },
      { status: 500 }
    )
  }
}
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy (first time)
vercel

# Follow prompts:
# - Link to existing project? No
# - Project name: my-pdp-app
# - Directory: ./
# - Override settings? No

# Set environment variables
vercel env add PRIVATE_KEY

# Deploy to production
vercel --prod
```

### Vercel Configuration

```json
// vercel.json (optional)
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "env": {
    "NEXT_PUBLIC_APP_NAME": "PDP-Payments Storage"
  }
}
```

### Automatic Deployments

```bash
# Connect to GitHub for automatic deployments
vercel --prod

# Every push to main branch will auto-deploy
# Pull requests get preview deployments
```

### Quick Deployment Summary

```bash
# 🚀 Deploy PDP-Payments app in 2 minutes:

# 1. Create Next.js app
npx create-next-app@latest my-pdp-app --typescript --tailwind --app
cd my-pdp-app

# 2. Install dependencies
npm install synapse-sdk react-dropzone

# 3. Add components (copy from examples above)
# 4. Set environment variables
# 5. Deploy to Vercel
vercel --prod

# ✅ Your PDP-Payments app is live!
```

## 5. Monitoring & Observability

### Logging
```javascript
import winston from 'winston'

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
})

// Usage
logger.info('File uploaded', { commp, size, storageProvider })
logger.error('Upload failed', { error: error.message, stack: error.stack })
```

### Metrics Collection
```javascript
// Simple metrics
class Metrics {
  constructor() {
    this.counters = new Map()
    this.gauges = new Map()
  }
  
  increment(name, value = 1) {
    this.counters.set(name, (this.counters.get(name) || 0) + value)
  }
  
  gauge(name, value) {
    this.gauges.set(name, value)
  }
  
  getMetrics() {
    return {
      counters: Object.fromEntries(this.counters),
      gauges: Object.fromEntries(this.gauges),
      timestamp: new Date().toISOString()
    }
  }
}

const metrics = new Metrics()

// Track uploads
metrics.increment('uploads.total')
metrics.increment('uploads.success')
metrics.gauge('balance.current', balance)
```

## 6. Best Practices Summary

### 🔒 **Security**
- ✅ Never hardcode private keys in client code
- ✅ Use Vercel environment variables for sensitive data
- ✅ Implement proper error handling in React components
- ✅ Consider server-side operations for sensitive actions

### 📈 **Performance**
- ✅ Use React hooks for state management
- ✅ Implement loading states and progress indicators
- ✅ Add retry logic with user feedback
- ✅ Optimize bundle size with Next.js

### 🔧 **Reliability**
- ✅ Graceful error handling with user-friendly messages
- ✅ Automatic balance monitoring in UI
- ✅ File upload progress tracking
- ✅ Vercel's built-in reliability and CDN

### 💰 **Cost Management**
- ✅ Display balance warnings to users
- ✅ Track upload costs in UI
- ✅ Implement usage quotas per user
- ✅ Monitor Vercel usage and costs

### 🚀 **Modern Development**
- ✅ TypeScript for type safety
- ✅ Tailwind CSS for rapid styling
- ✅ React hooks for clean state management
- ✅ Next.js App Router for modern patterns
- ✅ Vercel for zero-config deployment

## 🎉 Congratulations!

You've completed the **Developer Path** for PDP-Payments! You now know how to:

- ✅ **Set up** wallets and tokens
- ✅ **Use the SDK** for rapid development
- ✅ **Implement** complete storage + payment workflows
- ✅ **Monitor** storage and verify proofs
- ✅ **Deploy** to production securely

## What's Next?

### 🚀 **Build Your Application**
- Integrate PDP-Payments into your existing systems
- Customize the workflow for your specific needs
- Scale to handle your user base

### 🤖 **Advanced Usage**
- Explore the [AI Agent Path](setup-detailed.md) for direct contract control
- Implement custom storage provider selection
- Build advanced monitoring and analytics

### 🌟 **Join the Community**
- Share your implementation experiences
- Contribute to SDK improvements
- Help other developers get started

**Happy building with PDP-Payments!** 🎯
