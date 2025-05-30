# PDPTool Reference Guide

## Overview

PDPTool is a command-line utility that serves as the primary interface for interacting with Proof of Data Possession (PDP) Storage Providers. It handles file uploads, proof set management, and communication with Storage Provider services.

PDPTool acts as a bridge between client applications and Storage Providers, enabling:
- File preparation and upload to Storage Providers
- Proof set creation and management
- Root management within proof sets
- Proof generation for data possession verification
- Service authentication and configuration

## Installation

### From Curio Repository

PDPTool is part of the Curio project and can be installed from the PDP feature branch:

```bash
git clone -b feat/pdp https://github.com/filecoin-project/curio.git
cd curio
make pdp
```

This will build the `pdptool` executable in the project directory.

### Installation Verification

After installation, verify pdptool is working:

```bash
# Check if pdptool is accessible
./pdptool --help

# Or if installed globally
pdptool --help
```

## Configuration

### Environment Setup

PDPTool requires configuration to connect to Storage Provider services. This is typically done through environment variables or command-line arguments.

### Service Registration

Before using pdptool with a Storage Provider, you need:
1. **Service Name**: Unique identifier registered with the Storage Provider
2. **Service URL**: HTTP endpoint of the Storage Provider's PDP service
3. **Record Keeper**: Ethereum address of the Storage Provider's contract

### Working Directory

PDPTool creates and uses several files in its working directory:
- `pdpservice.json`: Service authentication credentials
- Temporary files during upload process
- Proof generation outputs

## Command Reference

### Authentication Commands

#### `create-service-secret`

Creates authentication credentials for communicating with Storage Provider services.

```bash
pdptool create-service-secret
```

**Purpose**: Generates `pdpservice.json` file containing service authentication credentials.

**When to use**: 
- First-time setup with a Storage Provider
- When authentication credentials need to be regenerated

**Output**: Creates `pdpservice.json` in the current working directory.

### File Management Commands

#### `prepare-piece`

Prepares a file for upload by processing it into the required format.

```bash
pdptool prepare-piece FILE_PATH
```

**Parameters**:
- `FILE_PATH`: Path to the file to be prepared

**Purpose**: Processes the file into a format suitable for PDP storage and generates necessary metadata.

**Example**:
```bash
pdptool prepare-piece /path/to/myfile.txt
```

#### `upload-file`

Uploads a prepared file to the Storage Provider.

```bash
pdptool upload-file --service-url SERVICE_URL --service-name SERVICE_NAME FILE_PATH
```

**Parameters**:
- `--service-url`: HTTP endpoint of the Storage Provider service
- `--service-name`: Registered service name with the Storage Provider
- `FILE_PATH`: Path to the file to upload

**Purpose**: Transfers the file to the Storage Provider and returns content identifiers (CIDs).

**Example**:
```bash
pdptool upload-file --service-url https://yablu.net --service-name pdp-service-name /path/to/myfile.txt
```

### Proof Set Management Commands

#### `create-proof-set`

Creates a new proof set with the Storage Provider.

```bash
pdptool create-proof-set --service-url SERVICE_URL --service-name SERVICE_NAME --recordkeeper RECORD_KEEPER --extra-data EXTRA_DATA
```

**Parameters**:
- `--service-url`: Storage Provider service endpoint
- `--service-name`: Registered service name
- `--recordkeeper`: Ethereum address of the Storage Provider's record keeper contract
- `--extra-data`: Hex-encoded additional data (often payment information)

**Purpose**: Initializes a new proof set that can contain multiple file roots.

**Example**:
```bash
pdptool create-proof-set --service-url https://yablu.net --service-name pdp-service-name --recordkeeper 0xdbE4bEF3F313dAC36257b0621e4a3BC8Dc9679a1 --extra-data 0x1234...
```

#### `get-proof-set-create-status`

Checks the status of proof set creation.

```bash
pdptool get-proof-set-create-status --service-url SERVICE_URL --service-name SERVICE_NAME --tx-hash TX_HASH
```

**Parameters**:
- `--service-url`: Storage Provider service endpoint
- `--service-name`: Registered service name
- `--tx-hash`: Transaction hash from proof set creation

**Purpose**: Polls the Storage Provider to check if proof set creation has completed.

**Example**:
```bash
pdptool get-proof-set-create-status --service-url https://yablu.net --service-name pdp-service-name --tx-hash 0xabc123...
```

#### `get-proof-set`

Retrieves information about an existing proof set.

```bash
pdptool get-proof-set --service-url SERVICE_URL --service-name SERVICE_NAME PROOF_SET_ID
```

**Parameters**:
- `--service-url`: Storage Provider service endpoint
- `--service-name`: Registered service name
- `PROOF_SET_ID`: ID of the proof set to query

**Purpose**: Gets detailed information about a proof set, including contained roots and their IDs.

**Example**:
```bash
pdptool get-proof-set --service-url https://yablu.net --service-name pdp-service-name 123
```

### Root Management Commands

#### `add-roots`

Adds a file root to an existing proof set.

```bash
pdptool add-roots --service-url SERVICE_URL --service-name SERVICE_NAME --proof-set-id PROOF_SET_ID --root ROOT_CID
```

**Parameters**:
- `--service-url`: Storage Provider service endpoint
- `--service-name`: Registered service name
- `--proof-set-id`: ID of the target proof set
- `--root`: Content Identifier (CID) of the file root to add

**Purpose**: Associates an uploaded file with a proof set for PDP verification.

**Example**:
```bash
pdptool add-roots --service-url https://yablu.net --service-name pdp-service-name --proof-set-id 123 --root bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi
```

#### `remove-roots`

Removes a file root from a proof set.

```bash
pdptool remove-roots --service-url SERVICE_URL --service-name SERVICE_NAME --proof-set-id PROOF_SET_ID --root-id ROOT_ID
```

**Parameters**:
- `--service-url`: Storage Provider service endpoint
- `--service-name`: Registered service name
- `--proof-set-id`: ID of the proof set
- `--root-id`: Numeric ID of the root to remove (not the CID)

**Purpose**: Removes a file from PDP verification within a proof set.

**Example**:
```bash
pdptool remove-roots --service-url https://yablu.net --service-name pdp-service-name --proof-set-id 123 --root-id 456
```

### Proof Generation Commands

#### `prove`

Generates proofs of data possession for submission to the blockchain.

```bash
pdptool prove --proof-set-id PROOF_SET_ID --verifier-address VERIFIER_ADDRESS --rpc-url RPC_URL
```

**Parameters**:
- `--proof-set-id`: ID of the proof set to generate proofs for
- `--verifier-address`: Ethereum address of the PDP verifier contract
- `--rpc-url`: RPC endpoint for blockchain interaction

**Purpose**: Creates cryptographic proofs that demonstrate continued possession of stored data.

**Example**:
```bash
pdptool prove --proof-set-id 123 --verifier-address 0x5A23b7df87f59A291C26A2A1d684AD03Ce9B68DC --rpc-url https://calibration.filfox.info/rpc/v1
```

## Common Workflows

### Complete File Storage Workflow

1. **Setup Authentication**:
   ```bash
   pdptool create-service-secret
   ```

2. **Prepare File**:
   ```bash
   pdptool prepare-piece /path/to/file.txt
   ```

3. **Upload File**:
   ```bash
   pdptool upload-file --service-url https://provider.com --service-name my-service /path/to/file.txt
   ```

4. **Create Proof Set** (if needed):
   ```bash
   pdptool create-proof-set --service-url https://provider.com --service-name my-service --recordkeeper 0x123... --extra-data 0xabc...
   ```

5. **Add File to Proof Set**:
   ```bash
   pdptool add-roots --service-url https://provider.com --service-name my-service --proof-set-id 123 --root bafybeig...
   ```

6. **Generate Proofs** (periodically):
   ```bash
   pdptool prove --proof-set-id 123 --verifier-address 0x456... --rpc-url https://rpc.endpoint.com
   ```

### Proof Set Management Workflow

1. **Check Proof Set Status**:
   ```bash
   pdptool get-proof-set --service-url https://provider.com --service-name my-service 123
   ```

2. **Add More Files**:
   ```bash
   pdptool add-roots --service-url https://provider.com --service-name my-service --proof-set-id 123 --root bafybeig...
   ```

3. **Remove Files**:
   ```bash
   pdptool remove-roots --service-url https://provider.com --service-name my-service --proof-set-id 123 --root-id 456
   ```

## Error Handling and Troubleshooting

### Common Issues

**Service Secret Missing**:
```
Error: pdpservice.json not found
```
**Solution**: Run `pdptool create-service-secret` first.

**Service Not Found**:
```
Error: service not registered
```
**Solution**: Verify SERVICE_NAME and SERVICE_URL with your Storage Provider.

**File Not Found**:
```
Error: pdptool executable not found
```
**Solution**: Check PDPTOOL_PATH configuration and file permissions.

**Connection Issues**:
```
Error: failed to connect to service
```
**Solution**: Verify SERVICE_URL is accessible and Storage Provider service is running.

### Best Practices

1. **Working Directory**: Always run pdptool from a consistent working directory to maintain service credentials.

2. **Error Handling**: Check command exit codes and parse stderr for error messages.

3. **Retry Logic**: Implement retry logic for network-dependent operations like `add-roots` and `get-proof-set-create-status`.

4. **Credential Management**: Protect `pdpservice.json` file and regenerate if compromised.

5. **Monitoring**: Regularly check proof set status and generate proofs as required by your SLA.

## Integration with Applications

PDPTool is designed to be integrated into larger applications. See the [Hot Vault Demo](../../examples/hot-vault.md) for a complete example of pdptool integration in a web application.

For Storage Provider configuration in applications, see the [MVP Configuration Guide](../../MVP.md).

## Next Steps

- [Creating a Proof Set](../guides/creating-proof-set.md)
- [Submitting Proofs](../guides/submitting-proofs.md)
- [Hot Vault Demo](../../examples/hot-vault.md)
- [MVP Configuration](../../MVP.md)
