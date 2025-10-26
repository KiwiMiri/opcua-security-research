# OPC UA Implementation Status (Complete & Updated)

| Implementation | Language | Version | Commit Hash / Package Info | Build Environment | Server Running |
|----------------|----------|---------|----------------------------|-------------------|----------------|
| python-opcua | Python | 0.98.13 | PyPI package: opcua==0.98.13 | OS: Linux aarch64 (Ubuntu 24.04); Python 3.12.3; pip install | **Yes** |
| open62541 | C | 1.5.0 | build version: 1.5.0 | GCC 13.3.0; CMake 3.28.3 | **Yes** - port 4840 |
| Node.js opcua | Node.js | 2.157.0 | npm package: node-opcua@2.157.0 | Node v18.19.1; npm (global install) | **Yes** |
| FreeOpcUa | Python | 0.90.6 | PyPI package: freeopcua==0.90.6 | OS: Linux aarch64; Python 3.12.3; pip install | **Yes** |
| Eclipse Milo | Java | 0.6.9(SDK) | pom.xml SDK version: 0.6.9 | Java OpenJDK 17.0.16; Maven 3.8.7 | **Yes** |
| S2OPC | C | 2554226f9 | git commit: 2554226f982c35c1e437cb0387eb4f347ea17865 (2025-10-20) | OS: Linux aarch64; GCC 13.3.0; CMake 3.28.3 | **Yes** - port 4840 |

## Server Details

- **open62541**: tutorial_server_firststeps (PID: 82678)
- **S2OPC**: pubsub_server (PID: 83902) - requires private key password
- **Port 4840**: Used by both open62541 and S2OPC (run one at a time)

## Start Scripts

- `scripts/start_s2opc_server.sh` - Start S2OPC server
- `scripts/start_open62541_server.sh` - Start open62541 server
- All servers can be stopped with: `pkill -f <server_name>`

