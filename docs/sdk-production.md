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

## 3. Express.js API Example

```javascript
// server.js
import express from 'express'
import multer from 'multer'
import ProductionSynapse from './production-synapse.js'

const app = express()
const upload = multer({ storage: multer.memoryStorage() })
let synapse

// Initialize Synapse
async function initializeServer() {
  synapse = await new ProductionSynapse().initialize()
  
  app.listen(3000, () => {
    console.log('🚀 PDP-Payments API server running on port 3000')
  })
}

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const health = await synapse.healthCheck()
    res.json({ status: 'ok', ...health })
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message })
  }
})

// File upload endpoint
app.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' })
    }
    
    const result = await synapse.storeFileWithRetry(req.file.buffer, {
      maxRetries: 3,
      retryDelay: 1000
    })
    
    res.json({
      success: true,
      commp: result.commp.toString(),
      storageProvider: result.storageProvider,
      txHash: result.txHash,
      filename: req.file.originalname,
      size: req.file.size
    })
    
  } catch (error) {
    console.error('Upload error:', error.message)
    res.status(500).json({ error: error.message })
  }
})

// File download endpoint
app.get('/download/:commp', async (req, res) => {
  try {
    const data = await synapse.storage.download(req.params.commp, {
      noVerify: false,
      withCDN: true
    })
    
    res.set({
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${req.params.commp}"`
    })
    
    res.send(Buffer.from(data))
    
  } catch (error) {
    console.error('Download error:', error.message)
    res.status(404).json({ error: 'File not found or retrieval failed' })
  }
})

// Start server
initializeServer().catch(console.error)
```

## 4. Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  pdp-payments-api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    volumes:
      - ./logs:/app/logs
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
- ✅ Never hardcode private keys
- ✅ Use environment variables for configuration
- ✅ Implement proper error handling
- ✅ Monitor for suspicious activity

### 📈 **Performance**
- ✅ Implement rate limiting
- ✅ Use connection pooling
- ✅ Add retry logic with exponential backoff
- ✅ Monitor and optimize costs

### 🔧 **Reliability**
- ✅ Health checks and monitoring
- ✅ Graceful error handling
- ✅ Automatic balance management
- ✅ Redundancy and failover

### 💰 **Cost Management**
- ✅ Monitor USDFC spending
- ✅ Optimize storage provider selection
- ✅ Implement usage quotas
- ✅ Track ROI and efficiency

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
