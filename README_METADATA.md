# OPC UA Research - Complete Metadata

## 퀵 참조 (Quick Reference)

### 구현체 버전
- **Python-opcua**: 0.98.13
- **FreeOpcUa**: 0.90.6  
- **Node.js opcua**: 2.157.0
- **Eclipse Milo**: 0.6.9 (SDK); 1.0-SNAPSHOT (빌드)
- **S2OPC**: 2554226f9 (2025-10-20)
- **open62541**: N/A (binary only)

### 환경
- **OS**: Linux aarch64 (Docker)
- **GCC**: 13.3.0
- **CMake**: 3.28.3
- **Java**: OpenJDK 17.0.16
- **Maven**: 3.8.7
- **Python**: 3.12.3
- **Node**: v18.19.1

## 상세 파일

- `METADATA_COMPLETE.txt`: 전체 메타데이터 (상세)
- `metadata_for_paper.tsv`: 논문용 TSV 표
- `IMPLEMENTATION_VERSIONS.md`: 구현체별 버전 정보

## 재현 방법

각 구현체별 서버 실행:

```bash
# Python-opcua
cd /root/opcua-research
source venv/bin/activate
python3 servers/python/opcua_server_anssi_multi.py

# Node.js
node servers/nodejs/opcua_server.js

# Eclipse Milo
cd servers/eclipse-milo/opcua-server
mvn clean package
java -jar target/opcua-server-1.0-SNAPSHOT.jar
```

클라이언트 실행:
```bash
python3 clients/python_client_anssi_downgrade.py downgrade
```

## 증거 파일

- **PCAP SHA256**: `METADATA_COMPLETE.txt`의 "## 8. PCAP Files" 섹션 참조
- **Binary SHA256**: `METADATA_COMPLETE.txt`의 "## 9. Binary Executables" 섹션 참조

## 생성 일시

2025-10-26T04:14:01Z
