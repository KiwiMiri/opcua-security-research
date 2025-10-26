# 현재 구축된 OPC UA 라이브러리들

## ✅ 구현 완료된 라이브러리

### 1. Python - python-opcua
- **라이브러리**: `opcua` (FreeOpcUA)
- **버전**: 0.98.13
- **디렉토리**: `servers/python/`
- **서버 파일**:
  - `opcua_server.py` - 기본 서버
  - `opcua_server_secure.py` - 보안 설정 (SignAndEncrypt)
  - `opcua_server_anssi.py` - ANSSI 시나리오용
  - 여러 다른 변형들

### 2. Node.js - node-opcua
- **라이브러리**: `node-opcua`
- **디렉토리**: `servers/nodejs/`
- **서버 파일**: `opcua_server.js`

### 3. Python - FreeOpcUa
- **라이브러리**: `freeopcua`
- **버전**: 0.90.6
- **디렉토리**: `servers/freeopcua/`
- **서버 파일**: `opcua_server.py`

### 4. Java - Eclipse Milo
- **라이브러리**: Eclipse Milo OPC UA SDK
- **디렉토리**: `servers/eclipse-milo/`
- **서버 파일**: `opcua-server/src/main/java/org/eclipse/milo/App.java`
- **빌드**: Maven (pom.xml)

## 🚧 준비 중인 라이브러리

### 5. C - open62541
- **디렉토리**: `servers/open62541/`
- **상태**: 디렉토리 존재, 빌드 필요

### 6. C - S2OPC
- **디렉토리**: `servers/s2opc/`
- **상태**: 디렉토리 존재, 다운로드 필요

### 7. .NET
- **디렉토리**: `servers/dotnet/`
- **상태**: 디렉토리 존재, 구현 필요

## 📊 실제 사용 중인 라이브러리

### Python - python-opcua (메인)
- ✅ 가장 많이 테스트됨
- ✅ 실제 PCAP 캡처 완료
- ✅ 평문 자격증명 전송 확인됨

### Node.js - node-opcua
- ⚠️ 서버 파일 존재하나 테스트 필요

### FreeOpcUa
- ⚠️ 서버 파일 존재하나 테스트 필요

### Eclipse Milo
- ⚠️ Java 코드 존재하나 빌드/테스트 필요

## 💡 정리

**현재 실제로 테스트된 라이브러리:**
1. **python-opcua** (FreeOpcUA) - ✅ 완전히 작동

**구축되어 있으나 아직 테스트 안 된 라이브러리:**
2. node-opcua (Node.js)
3. FreeOpcUa (Python)
4. Eclipse Milo (Java)
5. open62541 (C) - 빌드 필요
6. S2OPC (C) - 빌드 필요

**목표**: 모든 라이브러리로 테스트하여 비교 분석
