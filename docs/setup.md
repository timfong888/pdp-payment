# Step 1: Setup Wallet & USDFC Tokens

This is the first step in your Golden Path to success with PDP-Payments. You'll set up MetaMask with the Filecoin Calibration testnet and obtain USDFC stablecoin tokens for payments.

## Prerequisites

- **Google Chrome browser** (recommended for best compatibility)
- **MetaMask browser extension** installed
- **Disable all other wallet extensions** (to avoid conflicts)

## 1. Install and Configure MetaMask

### Install MetaMask
1. Visit [metamask.io](https://metamask.io/download.html)
2. Install the MetaMask extension for Chrome
3. Create a new wallet or import an existing one
4. **Important**: Disable all other wallet extensions to prevent conflicts

### Add Filecoin Calibration Testnet
1. Visit [Chainlist for Filecoin Calibration](https://chainlist.org/chain/314159)
2. Click "Connect Wallet" and approve the connection
3. Click "Add to MetaMask" for Filecoin Calibration Testnet
4. Approve adding the network in MetaMask

**Manual Setup (if needed):**
- Network Name: `Filecoin — Calibration Testnet`
- RPC URL: `https://api.calibration.node.glif.io/rpc/v1`
- Chain ID: `314159`
- Currency Symbol: `tFIL`
- Block Explorer: `https://calibration.filfox.info/`

## 2. Get Test FIL (tFIL) Tokens

1. Copy your wallet address from MetaMask
2. Visit the [Calibration Faucet](https://faucet.calibnet.chainsafe-fil.io/)
3. Paste your address and click "Send Funds"
4. You'll receive 100 tFIL (can request every 12 hours, max 2 times)
5. Verify the tokens appear in your MetaMask wallet

## 3. Get USDFC Stablecoin Tokens

USDFC is the stablecoin used for payments in the PDP system. You'll mint USDFC by depositing tFIL as collateral.

> **✅ Testnet Confirmation**: The USDFC protocol at [usdfc.secured.finance](https://usdfc.secured.finance/#/) **does support Filecoin Calibration testnet**. When you connect, make sure you're on the "Filecoin — Calibration Network" to mint testnet USDFC using your testnet tFIL.

### Access the USDFC Protocol
1. Visit [usdfc.secured.finance](https://usdfc.secured.finance/#/)
2. **Important**: Ensure you're connected to "Filecoin — Calibration Network" (not mainnet)
3. Click "Connect Wallet" and select MetaMask

### Mint USDFC Tokens
1. Click "Open Trove" in the top-left section
2. **Set Collateral Amount**: Enter amount of tFIL to deposit (e.g., 50 tFIL)
3. **Set Borrow Amount**: Enter USDFC to mint (keep collateral ratio above 150%)
   - Example: 50 tFIL → mint ~30 USDFC (167% collateral ratio)
4. Review the details:
   - **Liquidation Reserve**: 20 USDFC (refundable when closing trove)
   - **Borrowing Fee**: 0.5% one-time fee
   - **Total Debt**: Borrow amount + reserve + fee
5. Click "Confirm" and approve the MetaMask transaction

### Add USDFC Token to MetaMask
1. In MetaMask, click "Import tokens"
2. Enter USDFC contract address: `0xb3042734b608a1B16e9e86B374A3f3e389B4cDf0`
3. Token symbol: `USDFC`
4. Decimals: `18`
5. Click "Add Custom Token"

## 4. Verify Your Setup

You should now have:
- ✅ MetaMask connected to Filecoin Calibration testnet
- ✅ tFIL tokens in your wallet (for gas fees)
- ✅ USDFC tokens in your wallet (for storage payments)
- ✅ USDFC token visible in MetaMask

**Recommended Amounts:**
- **Minimum**: 10 tFIL + 10 USDFC
- **Recommended**: 50 tFIL + 30 USDFC

## Troubleshooting

### MetaMask Issues
- **Wrong network**: Ensure you're on "Filecoin — Calibration Testnet"
- **No tokens showing**: Try refreshing MetaMask or re-importing the USDFC token
- **Transaction fails**: Ensure you have enough tFIL for gas fees

### Faucet Issues
- **Rate limited**: Wait 12 hours between requests
- **Need more tokens**: Contact the team on [Filecoin Slack](https://filecoin.io/slack) #fil-pdp channel

### USDFC Minting Issues
- **Collateral ratio too low**: Increase tFIL deposit or decrease USDFC borrow amount
- **Transaction fails**: Ensure you have enough tFIL for gas fees

## Next Steps

🎉 **Congratulations!** You've completed Step 1 of the Golden Path.

**Next**: [Step 2: Configure JSON-RPC](setup-detailed.md) - Set up Filecoin JSON-RPC for blockchain interactions

## Additional Resources

- [USDFC Stablecoin Documentation](https://docs.secured.finance/)
- [Filecoin Calibration Network Info](https://docs.filecoin.io/networks/calibration/)
- [MetaMask Setup Guide](https://docs.filecoin.io/basics/assets/metamask-setup/)
