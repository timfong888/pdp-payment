# Setting Up Your First Payment Rail

This guide walks you through the process of creating and managing a payment rail in the FilOz Payments system.

## Prerequisites

- An Ethereum wallet with some ETH for gas
- ERC20 tokens to use for payments (e.g., USDC)
- Basic knowledge of Solidity and Ethereum transactions

## Step 1: Deploy or Connect to the Payments Contract

If you're using the existing FilOz deployment, you can connect to the contract at the official address. Otherwise, you can deploy your own instance.

```javascript
// Using ethers.js to connect to the Payments contract
const paymentsAbi = require('./abis/Payments.json');
const paymentsAddress = '0x805370387fA5Bd8053FD8f7B2da4055B9a4f8019'; // Example address
const payments = new ethers.Contract(paymentsAddress, paymentsAbi, signer);
```

## Step 2: Approve Token Spending

Before creating a rail, the payer needs to approve the Payments contract to spend their tokens:

```javascript
// Using ethers.js to approve token spending
const tokenAbi = require('./abis/ERC20.json');
const tokenAddress = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'; // USDC on Ethereum
const token = new ethers.Contract(tokenAddress, tokenAbi, signer);

// Approve a large amount to cover future payments
const approvalAmount = ethers.utils.parseUnits('1000', 6); // 1000 USDC (6 decimals)
await token.approve(paymentsAddress, approvalAmount);
```

## Step 3: Deposit Funds

The payer needs to deposit funds into the Payments contract:

```javascript
// Deposit funds into the Payments contract
const depositAmount = ethers.utils.parseUnits('100', 6); // 100 USDC
await payments.deposit(tokenAddress, payerAddress, depositAmount);
```

## Step 4: Create a Payment Rail

Now you can create a payment rail between the payer and payee:

```javascript
// Create a payment rail
const paymentRate = ethers.utils.parseUnits('0.01', 6); // 0.01 USDC per epoch
const lockupPeriod = 2880; // 1 day in epochs (assuming 30-second epochs)
const lockupFixed = ethers.utils.parseUnits('5', 6); // 5 USDC fixed lockup
const commissionRate = 250; // 2.5% commission

const tx = await payments.createRail(
    tokenAddress,
    payerAddress,
    payeeAddress,
    arbiterAddress, // Use zero address for no arbiter
    paymentRate,
    lockupPeriod,
    lockupFixed,
    commissionRate
);

// Wait for the transaction to be mined
const receipt = await tx.wait();

// Get the rail ID from the event logs
const railId = receipt.events[0].args.railId;
console.log(`Created rail with ID: ${railId}`);
```

## Step 5: Monitor the Rail Status

You can check the status of your rail:

```javascript
// Get rail details
const rail = await payments.getRail(railId);
console.log('Rail details:', {
    token: rail.token,
    from: rail.from,
    to: rail.to,
    paymentRate: ethers.utils.formatUnits(rail.paymentRate, 6),
    lockupPeriod: rail.lockupPeriod.toString(),
    settledUpTo: rail.settledUpTo.toString(),
    endEpoch: rail.endEpoch.toString()
});

// Check account balances
const payerAccount = await payments.accounts(tokenAddress, payerAddress);
console.log('Payer account:', {
    funds: ethers.utils.formatUnits(payerAccount.funds, 6),
    lockupCurrent: ethers.utils.formatUnits(payerAccount.lockupCurrent, 6),
    lockupRate: ethers.utils.formatUnits(payerAccount.lockupRate, 6)
});
```

## Step 6: Settle Payments

Payments can be settled by anyone, typically the payee:

```javascript
// Settle payments up to the current epoch
const currentEpoch = await ethers.provider.getBlockNumber();
await payments.settleRail(railId, currentEpoch);
```

## Step 7: Modify the Rail (Optional)

If needed, the rail operator can modify the rail parameters:

```javascript
// Modify the lockup parameters
await payments.modifyRailLockup(
    railId,
    3600, // New lockup period
    ethers.utils.parseUnits('6', 6) // New fixed lockup
);

// Modify the payment rate
await payments.modifyRailPayment(
    railId,
    ethers.utils.parseUnits('0.015', 6), // New payment rate
    0 // No one-time payment
);
```

## Step 8: Terminate the Rail (Optional)

When the service is no longer needed, the rail can be terminated:

```javascript
// Terminate the rail
await payments.terminateRail(railId);
```

## Step 9: Withdraw Funds

Users can withdraw their available funds:

```javascript
// Withdraw funds
const withdrawAmount = ethers.utils.parseUnits('50', 6); // 50 USDC
await payments.withdraw(tokenAddress, withdrawAmount);
```

## Integration with PDP

To integrate with the PDP system, you'll need to:

1. Create a proof set in the PDP system
2. Use an arbiter that checks PDP compliance
3. Include the payment rail ID in the PDP extradata

```javascript
// Create a proof set with payment information
const extraData = ethers.utils.defaultAbiCoder.encode(
    ['uint256', 'address'],
    [railId, paymentsAddress]
);

await pdpVerifier.createProofSet(
    pdpServiceAddress,
    extraData,
    { value: sybilFee }
);
```

## Example Arbiter Implementation

Here's a simple arbiter that reduces payments based on PDP faults:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IArbiter.sol";
import "./IPDPService.sol";

contract PDPArbiter is IArbiter {
    IPDPService public pdpService;
    
    constructor(address _pdpService) {
        pdpService = IPDPService(_pdpService);
    }
    
    function arbitratePayment(
        address token,
        address from,
        address to,
        uint256 railId,
        uint256 fromEpoch,
        uint256 toEpoch,
        uint256 amount
    ) external view override returns (ArbitrationResult memory) {
        // Get the proof set ID from the rail ID (implementation depends on your mapping)
        uint256 proofSetId = getProofSetIdForRail(railId);
        
        // Get fault count from PDP service
        uint256 faultCount = pdpService.getFaultCount(proofSetId, fromEpoch, toEpoch);
        
        // Calculate reduction (10% per fault, up to 100%)
        uint256 reductionPercent = faultCount * 10;
        if (reductionPercent > 100) reductionPercent = 100;
        
        uint256 reduction = amount * reductionPercent / 100;
        uint256 modifiedAmount = amount - reduction;
        
        return ArbitrationResult({
            modifiedAmount: modifiedAmount,
            settleUpto: toEpoch,
            note: string(abi.encodePacked("Reduced by ", faultCount, " faults"))
        });
    }
    
    function getProofSetIdForRail(uint256 railId) internal view returns (uint256) {
        // Implementation depends on how you map rails to proof sets
        // This could be stored in a mapping or derived from the rail ID
        return railId; // Simplified example
    }
}
```

## Troubleshooting

### Insufficient Funds

If you encounter "insufficient funds" errors:
- Check that the payer has deposited enough tokens
- Verify that the tokens are approved for the Payments contract
- Ensure the lockup amount isn't too high relative to the deposited funds

### Failed Settlements

If settlements fail:
- Check that the rail hasn't been terminated
- Verify that the settlement epoch is greater than the last settled epoch
- Ensure the arbiter contract (if used) is functioning correctly

## Next Steps

- [Implementing a Custom Arbiter](custom-arbiter.md)
- [Advanced Rail Management](advanced-rails.md)
- [Payments API Reference](../api/payments-contract.md)
