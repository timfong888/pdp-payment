### Repository List
#### Working Repo
You are only working with a single repo.  By working, this means you can:
- push code; pull code
- create and merge branches
- create issues; close issues
- create pull requests

Here is that primary working repo: https://github.com/timfong888/pdp-payment


#### Source Code Repos - Read Only
The following repos are `read-only`.

They are where the source code is for the intended documentation.

The primary interface for developers will be directly with the SDK (`synapse-sdk`)

However, the other repos represent the related primitives:

1. https://github.com/FilOzone/synapse-sdk (`synapse-sdk`)
2. https://github.com/FilOzone/pdp (`pdp`)
3. https://github.com/FilOzone/fws-payments (`fws-payments`)
4. https://github.com/FilOzone/hotvault-demo (`hotvault-demo`)
5. https://github.com/FilOzone/filecoin-services (`filecoin-services`)
6. https://github.com/FilOzone/pdp-explorer (`pdp-explorer`)

#### Existing Documentation
The following are documentation sites that, as needed, you should crawl to help you to build a single documentation site.  

But reference other sites as needed for developers and AI agents to go much more deeply.

1. USDFC Stablecoins Documentation: https://github.com/Secured-Finance/secured-finance-docs/tree/docs-optimize/usdfc-stablecoin/getting-started
2. Filcoin JSON-RPC: https://docs.filecoin.io/reference/json-rpc
3. MetaMask Docs (Snaps): https://docs.metamask.io/snaps/

#### MCP Server
Docs are available to the agent via the Context7 MCP Server: https://github.com/upstash/context7

The IDE or agent should add this MCP server based on those docs.

Remote Server:

```
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

Local Server:

```
{
  "servers": {
    "Context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

The relevant docs via MCP:

- Wagmi (for interacting with smart contracts): https://github.com/wevm/wagmi
- Solidity (for writing custom EVM smart contracts): https://context7.com/ethereum/solidity
- Vercel (deployment of the app from localhost): https://github.com/vercel/sdk
- Next.js (React framework for UI to deploy via Vercel): https://github.com/vercel/next.js

  



