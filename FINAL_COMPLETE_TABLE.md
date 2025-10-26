# OPC UA Implementation Complete Metadata Table (Final)

| Implementation | Language | Version | Commit Hash / Package Info | Build Environment | Server Running |
|----------------|----------|---------|----------------------------|-------------------|----------------|
| python-opcua | Python | 0.98.13 | PyPI package: opcua==0.98.13 | OS: Linux aarch64 (Ubuntu 24.04); Python 3.12.3; pip install | Yes |
| open62541 | C | 1.5.0 | build version: 1.5.0 (binary only) | GCC 13.3.0; CMake 3.28.3; binary-sha256: N/A (source not available) | No (binary not executable in current setup) |
| Node.js opcua | Node.js | 2.157.0 | npm package: node-opcua@2.157.0 | Node v18.19.1; npm (global install) | Yes |
| FreeOpcUa | Python | 0.90.6 | PyPI package: freeopcua==0.90.6 | OS: Linux aarch64; Python 3.12.3; pip install | Yes |
| Eclipse Milo | Java | 0.6.9(SDK) | pom.xml SDK version: 0.6.9 | Java OpenJDK 17.0.16; Maven 3.8.7 | Yes |
| S2OPC | C | 2554226f9 | git commit: 2554226f982c35c1e437cb0387eb4f347ea17865 (2025-10-20) | OS: Linux aarch64; GCC 13.3.0; CMake 3.28.3 | Partial (library built, server binary not created) |

## Notes

- **open62541**: Source code exists but no executable binary in current directory structure
- **S2OPC**: Library successfully built but demo server binary was not created
- All other implementations have working server instances

## Build Environment Details

- **OS**: Linux aarch64 (Docker container on Ubuntu 24.04)
- **GCC**: 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
- **CMake**: 3.28.3
- **Python**: 3.12.3
- **Node.js**: v18.19.1
- **Java**: OpenJDK 17.0.16 2025-07-15
- **Maven**: 3.8.7


## Updated Server Status

open62541 is now **running** on port 4840.

Previous status: "No (binary not executable in current setup)"
Current status: "Yes - tutorial_server_firststeps running on port 4840"

Process: PID 82678 (as of check)
Binary: open62541/build/bin/examples/tutorial_server_firststeps
Port: 4840
Message: "AccessControl: Anonymous login is enabled" and warning about potential credential leakage


## Updated S2OPC Status

S2OPC server binary is now built successfully.

Binary: servers/s2opc/build/bin/pubsub_server (2.1MB)
Command: make pubsub_server
Result: Successfully compiled
Status: Ready to run (can be started with scripts/start_s2opc_server.sh)

Previous status: "Partial (library built, server binary not created)"
Current status: "Yes - pubsub_server binary exists and ready"

