# Smart Contracts Reference

This page provides comprehensive information about all deployed smart contracts in the FilOz ecosystem, including addresses, ABIs, and usage examples.

## Contract Addresses

### Filecoin Mainnet

| Contract | Address | Purpose | Status |
|----------|---------|---------|---------|
| **PDP Verifier** | `0x9C65E8E57C98cCc040A3d825556832EA1e9f4Df6` | Proof verification and management | ✅ Active |
| **PDP Service** | `0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019` | Storage service implementation | ✅ Active |
| **Payments** | `0x8BA1f109551bD432803012645Ac136ddd64DBA72` | Payment rails and settlement | ✅ Active |

### Filecoin Calibration Testnet

| Contract | Address | Purpose | Status |
|----------|---------|---------|---------|
| **PDP Verifier** | `0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC` | Proof verification and management | ✅ Active |
| **PDP Service** | `0x6170dE2b09b404776197485F3dc6c968Ef948505` | Storage service implementation | ✅ Active |
| **Payments** | `0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A` | Payment rails and settlement | ✅ Active |
| **USDFC Token** | `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0` | Stablecoin for payments | ✅ Active |

## Network Configuration

### Filecoin Mainnet
- **Chain ID**: `314`
- **RPC URL**: `https://api.node.glif.io/rpc/v1`
- **Block Explorer**: `https://filfox.info/`
- **Currency**: FIL

### Filecoin Calibration Testnet
- **Chain ID**: `314159`
- **RPC URL**: `https://api.calibration.node.glif.io/rpc/v1`
- **Block Explorer**: `https://calibration.filfox.info/`
- **Currency**: tFIL (testnet FIL)

## Contract ABIs

### PDP Verifier Contract

**Key Functions:**
```solidity
// Create a new proof set
function createProofSet(address service, bytes calldata extraData) external payable returns (uint256 setId)

// Submit proofs for a proof set
function submitProofs(uint256 setId, bytes[] calldata proofs) external

// Get proof set information
function getProofSet(uint256 setId) external view returns (ProofSet memory)

// Get next challenge epoch
function getNextChallengeEpoch(uint256 setId) external view returns (uint256)

// Check if proofs are required
function isProofRequired(uint256 setId) external view returns (bool)
```

**Events:**
```solidity
event ProofSetCreated(uint256 indexed setId, address indexed owner, address indexed service)
event ProofsSubmitted(uint256 indexed setId, uint256 indexed epoch, bytes32 indexed root)
event ProofSetFaulted(uint256 indexed setId, uint256 indexed epoch)
```

### Payments Contract

**Key Functions:**
```solidity
// Create a payment rail
function createRail(
    address token,
    address from,
    address to,
    address arbiter,
    uint256 rate,
    uint256 lockupPeriod,
    uint256 lockupFixed,
    uint256 commissionRate
) external returns (uint256 railId)

// Deposit funds
function deposit(address token, address to, uint256 amount) external

// Settle payments
function settleRail(uint256 railId, uint256 epoch) external

// Get account information
function accounts(address token, address owner) external view returns (Account memory)

// Get rail information
function rails(uint256 railId) external view returns (Rail memory)
```

**Events:**
```solidity
event RailCreated(uint256 indexed railId, address indexed from, address indexed to)
event Deposit(address indexed token, address indexed to, uint256 amount)
event Settlement(uint256 indexed railId, uint256 indexed epoch, uint256 amount)
event RailModified(uint256 indexed railId, uint256 newRate, uint256 newLockup)
```

### USDFC Token Contract (ERC20)

**Standard ERC20 Functions:**
```solidity
function balanceOf(address owner) external view returns (uint256)
function transfer(address to, uint256 value) external returns (bool)
function approve(address spender, uint256 value) external returns (bool)
function allowance(address owner, address spender) external view returns (uint256)
```

## Usage Examples

### JavaScript/TypeScript Integration

```javascript
// Contract configuration
const CONTRACTS = {
  // Calibration Testnet
  PDP_VERIFIER: '0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC',
  PDP_SERVICE: '0x6170dE2b09b404776197485F3dc6c968Ef948505',
  PAYMENTS: '0xc5e1333D3cD8a3F1f8A9f9A116f166cBD0bA307A',
  USDFC_TOKEN: '0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0',
}

// Network configuration
const NETWORKS = {
  calibration: {
    chainId: 314159,
    rpcUrl: 'https://api.calibration.node.glif.io/rpc/v1',
    blockExplorer: 'https://calibration.filfox.info/',
  },
  mainnet: {
    chainId: 314,
    rpcUrl: 'https://api.node.glif.io/rpc/v1',
    blockExplorer: 'https://filfox.info/',
  }
}
```

### Wagmi Configuration

```typescript
import { createConfig, http } from 'wagmi'
import { filecoin, filecoinCalibration } from 'wagmi/chains'

export const config = createConfig({
  chains: [filecoinCalibration, filecoin],
  transports: {
    [filecoinCalibration.id]: http('https://api.calibration.node.glif.io/rpc/v1'),
    [filecoin.id]: http('https://api.node.glif.io/rpc/v1'),
  },
})
```

### Viem Configuration

```typescript
import { createPublicClient, createWalletClient, http } from 'viem'
import { filecoinCalibration } from 'viem/chains'

const publicClient = createPublicClient({
  chain: filecoinCalibration,
  transport: http('https://api.calibration.node.glif.io/rpc/v1')
})

const walletClient = createWalletClient({
  chain: filecoinCalibration,
  transport: http('https://api.calibration.node.glif.io/rpc/v1')
})
```

## Gas and Fees

### Typical Gas Costs (Calibration Testnet)

| Operation | Estimated Gas | Cost (tFIL) |
|-----------|---------------|-------------|
| Create Proof Set | ~200,000 | ~0.002 tFIL |
| Submit Proofs | ~150,000 | ~0.0015 tFIL |
| Create Payment Rail | ~180,000 | ~0.0018 tFIL |
| Deposit Funds | ~80,000 | ~0.0008 tFIL |
| Settle Payments | ~120,000 | ~0.0012 tFIL |

### Additional Fees

- **Sybil Fee (Proof Sets)**: 0.1 tFIL (paid to PDP Verifier)
- **USDFC Transactions**: Standard ERC20 gas costs
- **Network Fees**: Variable based on network congestion

## Security Considerations

### Contract Verification
- All contracts are verified on the respective block explorers
- Source code is available for audit
- Contracts follow standard security practices

### Best Practices
1. **Always verify contract addresses** before interacting
2. **Use appropriate gas limits** to avoid failed transactions
3. **Check allowances** before token transfers
4. **Monitor transaction status** for confirmation
5. **Use testnet first** for development and testing

### Known Limitations
- Proof submission has time windows (challenge epochs)
- Payment settlements require sufficient account balance
- Some operations require specific contract states

## Development Tools

### Block Explorers
- **Mainnet**: [https://filfox.info/](https://filfox.info/)
- **Calibration**: [https://calibration.filfox.info/](https://calibration.filfox.info/)

### RPC Endpoints
- **Mainnet**: `https://api.node.glif.io/rpc/v1`
- **Calibration**: `https://api.calibration.node.glif.io/rpc/v1`

### Faucets
- **Calibration tFIL**: [https://faucet.calibration.fildev.network/](https://faucet.calibration.fildev.network/)
- **USDFC Tokens**: Available through the setup guide

## Integration Guides

For detailed integration examples, see:
- **[Contracts Integration Guide](contracts-guide.md)** - Direct contract interaction patterns
- **[SDK Documentation](sdk/sdk-quickstart.md)** - High-level SDK integration
- **[Hot Vault Examples](examples/hot-vault.md)** - Complete application examples

## Support

For technical support:
- **Documentation**: [Navigation Guide](navigation.md)
- **GitHub Issues**: [pdp-payment repository](https://github.com/timfong888/pdp-payment/issues)
- **Example Code**: [Hot Vault Demo](https://github.com/FilOzone/hotvault-demo)
