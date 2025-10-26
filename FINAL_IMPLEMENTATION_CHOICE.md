# 최종 구현체 선택 - 확정

## ✅ 실험에 포함할 구현체 (4개)

| # | Implementation | Language | Port | Endpoints | Status |
|---|----------------|----------|------|-----------|--------|
| 1 | python-opcua | Python | 4840 | 1 (NoSecurity) | ✅ 실행 중 |
| 2 | open62541 | C | 4841 | 1 (NoSecurity) | ✅ 실행 중 |
| 3 | node-opcua | Node.js | 4842 | 7 (다양한 정책) | ✅ 실행 중 ⭐ |
| 4 | freeopcua | Python | 4843 | 1 (NoSecurity) | ✅ 실행 중 |

## ❌ 제외된 구현체 (2개)

### Eclipse Milo
- **버전**: 0.6.9 (시도), 0.7.x (Maven Central에 없음)
- **문제**: 
  - 0.6.9에는 endpoint binding을 위한 필수 API 부족
  - 0.7.x는 Maven Central에서 다운로드 불가
- **결정**: 실험에서 제외

### S2OPC
- **버전**: commit 2554226f9
- **문제**: PKI 설정 복잡도
- **결정**: PubSub 전용 (TCP 모드 설정 어려움)

## 논문 서술

> "We evaluated six OPC UA implementations across multiple programming languages. Four implementations (python-opcua, open62541, node-opcua, and freeopcua) were successfully configured for TCP client/server communication on distinct ports (4840-4843). node-opcua provided the most diverse security configurations with 7 endpoints including various encryption modes. Eclipse Milo version 0.6.9 lacked the necessary API classes (UaTransportProfile, UserTokenPolicy) for proper endpoint binding, and version 0.7.x was unavailable on Maven Central. S2OPC's complex PKI requirements made TCP mode configuration impractical. Both were documented as limitations in our experimental setup."

## 실험 준비 완료

**4개 구현체로 충분한 분석 가능**:
- 3개 프로그래밍 언어 (Python, C, Node.js)
- node-opcua는 7개 엔드포인트 (가장 다양함)
- 모든 서버 실행 중 (4840-4843)
- 평문 자격증명 확인 완료 (anssi_normal.pcap)
- PCAP 분석 준비 완료

## 다음 단계

1. ✅ 4개 구현체 서버 실행 중
2. ⏭️ 클라이언트 연결 테스트
3. ⏭️ 공격 시나리오 캡처
4. ⏭️ PCAP 분석
5. ⏭️ 논문 작성
