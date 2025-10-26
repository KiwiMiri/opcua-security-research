# Offered Endpoints Information (Normal Mode)

## Table Column: `offered_endpoints_normal`

This column should list the security policies and modes offered by each server during normal (non-attack) operation.

## Data Collection Method

To collect this information for each server:

1. Start the server
2. Connect with an OPC UA client
3. Call `GetEndpoints()` discovery service
4. Record the returned endpoint descriptions

## Expected Values (Based on Server Configurations)

### python-opcua (Port 4840)
**Configuration**: `opcua_server_anssi_multi.py`
- NoSecurity / None
- Basic256Sha256 / Sign  
- Basic256Sha256 / SignAndEncrypt

### open62541 (Port 4841)
**Configuration**: tutorial_server_firststeps (default)
- **Expected**: NoSecurity / None (default for tutorial)

### node-opcua (Port 4842)
**Configuration**: `opcua_server.js`
- NoSecurity / None (anonymous allowed)

### freeopcua (Port 4843)
**Configuration**: `opcua_server.py`
- NoSecurity / None

### eclipse-milo (Port 4844)
**Configuration**: `Server.java`
- NoSecurity / None (default)

### S2OPC (Port 4845)
**Status**: TCP mode not working
- PubSub mode: UDP multicast

## Collection Script

```bash
# Start all servers
./scripts/start_all_servers.sh

# Collect endpoints
source venv/bin/activate
python3 scripts/get_endpoints_info.py

# Results saved to endpoints_info.json
```

## Recommended Format for Table

Format: `Policy/Mode` (comma-separated for multiple endpoints)

Examples:
- `NoSecurity/None`
- `Basic256Sha256/Sign,Basic256Sha256/SignAndEncrypt`
- `Basic256Sha256/SignAndEncrypt`
- `NoSecurity/None,Basic256Sha256/SignAndEncrypt`

## Current Status

**Note**: Servers are currently not running. Start them first before collecting endpoint information.

To collect the data:
1. Start all servers (see `scripts/start_all_servers.sh`)
2. Run `python3 scripts/get_endpoints_info.py`
3. Extract and format the results for the table
