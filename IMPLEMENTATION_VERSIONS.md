# OPC UA 구현체 버전 정보

생성 일시: $(date +"%Y-%m-%d %H:%M:%S")

## 구현체별 버전

### 1. Python-opcua
- **패키지명**: opcua
- **버전**: 0.98.13
- **설치 경로**: venv/lib/python3.12/site-packages/opcua
- **PyPI**: https://pypi.org/project/opcua/

### 2. Node.js opcua (node-opcua)
- **패키지명**: node-opcua
- **버전**: 2.157.0
- **npm**: https://www.npmjs.com/package/node-opcua
- **GitHub**: https://github.com/node-opcua/node-opcua

### 3. open62541
- **상태**: 컴파일된 바이너리 (소스 복사됨)
- **원본**: https://open62541.org/
- **참고**: 서버 바이너리만 사용됨

### 4. FreeOpcUa
- **패키지명**: freeopcua
- **버전**: 0.90.6
- **PyPI**: https://pypi.org/project/freeopcua/
- **참고**: Python-opcua 기반

### 5. Eclipse Milo
- **프로젝트**: opcua-server
- **버전**: 1.0-SNAPSHOT
- **최종 빌드**: Maven
- **GitHub**: https://github.com/eclipse/milo
- **문서**: https://github.com/eclipse/milo

### 6. S2OPC
- **소스**: GitLab
- **Commit**: 2554226f982c35c1e437cb0387eb4f347ea17865
- **Branch**: master
- **Commit 날짜**: 2025-10-20 15:02:07 +0200
- **커밋 메시지**: Ticket #1548: WriteRequest builder: add documentation on value provided
- **리포지토리**: https://gitlab.com/systerel/S2OPC

## 확인 방법

### Python-opcua
```bash
pip show opcua
```

### Node.js opcua
```bash
npm list -g node-opcua
```

### FreeOpcUa
```bash
pip show freeopcua
```

### S2OPC
```bash
cd servers/s2opc
git log -1
```

### Eclipse Milo
```bash
cd servers/eclipse-milo/opcua-server
mvn help:evaluate -Dexpression=project.version
```

## 참고 사항

- open62541은 컴파일된 바이너리만 사용하여 버전을 확인할 수 없습니다.
- Eclipse Milo는 커스텀 프로젝트이므로 SNAPSHOT 버전입니다.
- S2OPC는 최신 master 브랜치에서 직접 클론했습니다.

