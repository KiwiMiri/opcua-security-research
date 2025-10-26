# OPC UA Implementation Complete Table (With Server Ports)

| Implementation | Language | Version | Commit Hash / Package Info | Build Environment | Server Running | Server Port |
|----------------|----------|---------|----------------------------|-------------------|----------------|-------------|
| python-opcua | Python | 0.98.13 | PyPI package: opcua==0.98.13 | OS: Linux aarch64 (Ubuntu 24.04); Python 3.12.3; pip install | Yes | 4850 |
| open62541 | C | 1.5.0 | build version: 1.5.0 | GCC 13.3.0; CMake 3.28.3 | Yes | 4840 |
| Node.js opcua | Node.js | 2.157.0 | npm package: node-opcua@2.157.0 | Node v18.19.1; npm (global install) | Yes | 4841 |
| FreeOpcUa | Python | 0.90.6 | PyPI package: freeopcua==0.90.6 | OS: Linux aarch64; Python 3.12.3; pip install | Yes | 4842 |
| Eclipse Milo | Java | 0.6.9(SDK) | pom.xml SDK version: 0.6.9 | Java OpenJDK 17.0.16; Maven 3.8.7 | Yes | 4844 |
| S2OPC | C | 2554226f9 | git commit: 2554226f982c35c1e437cb0387eb4f347ea17865 (2025-10-20) | OS: Linux aarch64; GCC 13.3.0; CMake 3.28.3 | Yes | 4840 |

## Note on Ports

- **4840**: open62541 (currently running)
- **4840**: S2OPC (can run on this port, but conflicts with open62541)
- **4841**: Node.js opcua
- **4842**: FreeOpcUa
- **4844**: Eclipse Milo
- **4850**: python-opcua (ANSSI scenario)

## Server Configurations

Servers can be started with different scripts. Only one server per port can run at a time.

