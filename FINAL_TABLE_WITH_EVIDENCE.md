# OPC UA Implementation Complete Table with Evidence PCAPs

| Implementation | Language | Version | Commit Hash / Package Info | Build Environment | Server Running | Server Port | Evidence PCAP |
|----------------|----------|---------|----------------------------|-------------------|----------------|-------------|---------------|
| python-opcua | Python | 0.98.13 | PyPI package: opcua==0.98.13 | OS: Linux aarch64 (Ubuntu 24.04); Python 3.12.3; pip install | Yes | 4850 | pcaps/python_attack.pcap |
| open62541 | C | 1.5.0 | build version: 1.5.0 | GCC 13.3.0; CMake 3.28.3 | Yes | 4840 | (empty) |
| Node.js opcua | Node.js | 2.157.0 | npm package: node-opcua@2.157.0 | Node v18.19.1; npm (global install) | Yes | 4841 | pcaps/nodeopcua_attack.pcap |
| FreeOpcUa | Python | 0.90.6 | PyPI package: freeopcua==0.90.6 | OS: Linux aarch64; Python 3.12.3; pip install | Yes | 4842 | pcaps/freeopcua_attack.pcap |
| Eclipse Milo | Java | 0.6.9(SDK) | pom.xml SDK version: 0.6.9 | Java OpenJDK 17.0.16; Maven 3.8.7 | Yes | 4844 | pcaps/milo_normal.pcap |
| S2OPC | C | 2554226f9 | git commit: 2554226f982c35c1e437cb0387eb4f347ea17865 (2025-10-20) | OS: Linux aarch64; GCC 13.3.0; CMake 3.28.3 | Yes | 4840 | pcaps/s2opc_attack.pcap |

## Available PCAP Files

Normal captures:
- pcaps/python_normal.pcap
- pcaps/node_normal.pcap
- pcaps/freeopcua_normal.pcap
- pcaps/milo_normal.pcap
- pcaps/open62541_normal.pcap

Attack captures:
- pcaps/python_attack.pcap
- pcaps/node_attack.pcap (nodeopcua_attack.pcap)
- pcaps/freeopcua_attack.pcap
- pcaps/milo_attack.pcap
- pcaps/open62541_attack.pcap
- pcaps/anssi_attack.pcap, pcaps/anssi_normal.pcap

