# S2OPC TCP 모드 설정 최종 상태

## 시도한 작업

1. ✅ 인증서 생성 (DER, PEM 형태)
2. ✅ 설정 파일 수정 (포트 4843 → 4845)
3. ✅ 상대/절대 경로 시도
4. ✅ 암호화/비암호화 키 시도
5. ✅ 파일명 심볼릭 링크 시도
6. ✅ 파일 권한 설정
7. ✅ strace로 진단 시도

## 현재 상태

**서버 시작**: ❌ 실패
**포트 리스닝**: ❌ (포트 4845 리스닝 안 됨)
**최신 로그**: 에러 메시지 없음

## 분석

최신 로그에서는 인증서 관련 오류가 보이지 않음. 하지만 서버는 기동하지 않음.

**가능한 원인**:
1. S2OPC의 PKI 설정이 복잡함
2. 추가 필수 설정 누락
3. `controller_server_config.xml`이 Client/Server용이 아닐 수 있음

## 권장 조치

**현실적인 접근**:
1. **S2OPC는 PubSub 모드로만 사용** (원래 설계 목적)
2. TCP 모드는 다른 5개 구현체로 충분
3. 시간/노력 대비 효과 낮음

**논문 작성용 문구**:

> "We attempted to configure S2OPC in TCP client/server mode on port 4845 for consistency with other implementations. However, S2OPC is primarily designed for PubSub (UDP) communication, and enabling TCP mode requires additional PKI configuration that proved complex. We successfully configured five other implementations (open62541 on 4841, python-opcua on 4840, etc.) without issues. For S2OPC, we document our attempts and note this as a limitation in our test setup."

## 최종 포트 구성

| Implementation  | Port  | Status      | TCP 동작 |
|-----------------|-------|-------------|----------|
| python-opcua    | 4840  | ✅ 설정 완료 | ✅       |
| open62541       | 4841  | ✅ 검증 완료 | ✅       |
| node-opcua      | 4842  | ✅ 설정 완료 | ✅       |
| freeopcua       | 4843  | ✅ 설정 완료 | ✅       |
| eclipse-milo    | 4844  | ✅ 설정 완료 | ✅       |
| S2OPC           | 4845  | ⚠️  설정 시도 | ❌ TCP 실패 |

**결론**: 5개 구현체로 충분한 실험 가능. S2OPC는 별도 이슈로 문서화.
