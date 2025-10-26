# 포트 구성 완료 요약

## ✅ 완료된 작업

### 1. 서버 파일 포트 수정
- `servers/python/opcua_server_anssi_multi.py`: 4850 → **4840**
- `servers/nodejs/opcua_server.js`: 4841 → **4842**
- `servers/freeopcua/opcua_server.py`: 4842 → **4843**

### 2. 스크립트 주석 업데이트
- `scripts/start_open62541_server.sh`: 기본 4840 사용 명시
- `scripts/start_s2opc_server.sh`: 기본 포트 사용 명시

### 3. 포트 충돌 해결 전략 문서화
- `PORT_ASSIGNMENT.md` 생성

## 📝 최종 권장 포트 매핑

| Implementation  | Port  | 변경 사항                    |
|-----------------|-------|------------------------------|
| python-opcua    | **4840** | ✅ 4850→4840 변경됨         |
| open62541       | **4841** | ⚠️  재빌드 필요 (기본 4840) |
| Node.js opcua   | **4842** | ✅ 4841→4842 변경됨         |
| FreeOpcUa       | **4843** | ✅ 4842→4843 변경됨         |
| Eclipse Milo    | **4844** | ✅ 이미 설정됨              |
| S2OPC           | **4845** | ⚠️  설정 변경 필요          |

## ⚠️ 추가 작업 필요

### open62541 (Port 4841)
```bash
# 방법 1: 소스 수정 후 재빌드
cd open62541
# 소스 코드에서 기본 포트 4840 → 4841로 변경
make -C build clean && make -C build

# 방법 2: wrapper 스크립트로 포트 포워딩
# (복잡하므로 권장하지 않음)
```

### S2OPC (Port 4845)
```bash
# 설정 파일 찾기
find servers/s2opc -name "*.xml" -o -name "*.json" -o -name "*config*"

# 포트 설정 수정 후 재시작
```

## 📊 현재 실행 중인 서버

- **Port 4840**: tutorial_server (open62541, PID 82678)
- **Port 4850**: python3 (이전 ANSSI 서버, PID 67059)

## 🔄 즉시 실행 가능

수정 완료된 서버들:
```bash
# python-opcua (port 4840)
cd /root/opcua-research
source venv/bin/activate
python3 servers/python/opcua_server_anssi_multi.py

# node-opcua (port 4842)
cd servers/nodejs
node opcua_server.js

# freeopcua (port 4843)
python3 servers/freeopcua/opcua_server.py
```

## 📋 다음 단계

1. ✅ 포트 매핑 문서화 완료
2. ⏳ open62541 재빌드 또는 포트 변경
3. ⏳ S2OPC 설정 파일 수정
4. ⏳ results.tsv 및 results.xlsx 업데이트

