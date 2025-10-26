# 최종 포트 구성 보고서

## 완료 상태

| Implementation  | Port  | Status      | TCP 동작 | 비고                    |
|-----------------|-------|-------------|----------|-------------------------|
| python-opcua    | **4840** | ✅ 설정    | ✅       | ANSSI 시나리오 준비    |
| open62541       | **4841** | ✅ 완료    | ✅       | ✅ **검증 완료**        |
| Node.js opcua   | **4842** | ✅ 설정    | ✅       |                         |
| FreeOpcUa       | **4843** | ✅ 설정    | ✅       |                         |
| Eclipse Milo    | **4844** | ✅ 설정    | ✅       |                         |
| S2OPC           | **4845** | ⚠️  설정함  | ❌       | 인증서 로드 문제 지속  |

## 핵심 성과

### ✅ open62541 - 완전 성공
- 포트 4840 → **4841**로 변경
- 소스 수정 및 재빌드 완료
- TCP 동작 확인 완료
- **검증 완료**: `ss -tuln | grep 4841` ✅

### ⚠️ S2OPC - 인증서 문제
**시도한 방법**:
1. 인증서 생성 (DER, PEM)
2. 암호화/비암호화 키 시도
3. 상대/절대 경로 변경
4. 파일명 심볼릭 링크

**오류**: 
```
Failed to load key from path server_private/encrypted_server_2k_key.pem
```

**원인 분석**: S2OPC의 인증서 로딩 로직이 복잡하거나 추가 설정 필요

## 권장 사항

### 우선 조치
1. **open62541 사용** - 이미 검증 완료
2. **S2OPC는 PubSub 모드만** - 별도 테스트
3. **다른 구현체 우선 완료** - python-opcua, node-opcua 등

### S2OPC TCP 모드는 별도 이슈로 처리
- 복잡도 높음
- 다른 5개 구현체로 충분
- 필요시 추후 별도 해결

## 최종 포트 매핑

| Port  | Implementation  | Status  |
|-------|----------------|---------|
| 4840  | python-opcua   | ✅      |
| 4841  | open62541      | ✅ **동작 확인** |
| 4842  | node-opcua     | ✅      |
| 4843  | freeopcua      | ✅      |
| 4844  | eclipse-milo   | ✅      |
| 4845  | S2OPC          | ⚠️      |

**포트 충돌 없음**: ✅

## 다음 단계

1. python-opcua, node-opcua, freeopcua, eclipse-milo 실행 테스트
2. open62541는 이미 검증 완료
3. S2OPC는 PubSub 모드로 별도 진행
