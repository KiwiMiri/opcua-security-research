# OPC UA Server Port Assignment

## 권장 포트 배치 (Port Conflict Resolution)

| Implementation  | Port | Status  | Notes                              |
|-----------------|------|---------|-------------------------------------|
| python-opcua    | 4840 | Modified| ANSSI scenario (was 4850)           |
| open62541       | 4840 | Default | 기본 4840 사용 (변경 필요 시 빌드) |
| Node.js opcua   | 4842 | Modified| Was 4841                           |
| FreeOpcUa       | 4843 | Modified| Was 4842                           |
| Eclipse Milo    | 4844 | Ok      | Already configured                  |
| S2OPC           | 4840 | Default | 기본 4840 사용 (설정 변경 필요)     |

## ⚠️ 현재 포트 충돌

**Port 4840**: python-opcua, open62541, S2OPC 모두 사용
- **해결 방안**:
  1. python-opcua를 4841로 변경 (권장)
  2. open62541과 S2OPC는 재빌드 필요

## 권장 최종 포트 매핑

| Implementation  | Recommended Port | Action          |
|-----------------|------------------|-----------------|
| python-opcua    | 4840             | Keep (changed)  |
| open62541       | 4841             | Rebuild needed  |
| Node.js opcua   | 4842             | Keep (changed)  |
| FreeOpcUa       | 4843             | Keep (changed)  |
| Eclipse Milo    | 4844             | Keep            |
| S2OPC           | 4845             | Config needed   |

## Modified Files

1. `servers/python/opcua_server_anssi_multi.py`: 4850 → 4840
2. `servers/nodejs/opcua_server.js`: 4841 → 4842
3. `servers/freeopcua/opcua_server.py`: 4842 → 4843
4. `scripts/start_open62541_server.sh`: 주석 추가 (기본 4840)
5. `scripts/start_s2opc_server.sh`: 주석 추가 (기본 포트)

## Next Steps

1. open62541: 포트 4841로 재빌드 또는 바이너리 수정
2. S2OPC: 설정 파일에서 포트 4845 지정
3. 결과 테이블 업데이트: `results.tsv`와 `results.xlsx` 반영

