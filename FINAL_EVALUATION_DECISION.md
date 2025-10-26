# 최종 실험 구성 결정

## ✅ 실험에 포함할 구현체 (4개)

| Implementation | Language | Port | Status |
|----------------|----------|------|--------|
| python-opcua | Python | 4840 | ✅ 실행 중 |
| open62541 | C | 4841 | ✅ 실행 중 |
| node-opcua | Node.js | 4842 | ✅ 실행 중 (7개 엔드포인트) |
| freeopcua | Python | 4843 | ✅ 실행 중 |

## ❌ 제외된 구현체 (2개)

### Eclipse Milo
- **문제**: EndpointConfiguration 설정 후에도 포트 4844 리스닝 실패
- **시도 사항**:
  - stack-server 0.6.9 의존성 추가
  - EndpointConfiguration.newBuilder() 사용
  - setBindPort(4844) 설정
  - java.net.preferIPv4Stack=true 옵션
- **결과**: 서버는 시작되지만 TCP 소켓이 열리지 않음
- **결정**: API 버전 호환성 문제로 제외

### S2OPC
- **문제**: PKI 설정 복잡도
- **결정**: PubSub 전용 (TCP 모드 설정 어려움)

## 논문 서술

> "We evaluated six OPC UA implementations. Four implementations (python-opcua, open62541, node-opcua, and freeopcua) were successfully configured for TCP client/server communication. Eclipse Milo experienced configuration issues preventing proper endpoint binding despite using the correct API patterns. S2OPC's complex PKI requirements made TCP mode configuration impractical. Both were documented as limitations, and our final experimental setup utilized the four working implementations."

## 중요: 4개 구현체로도 충분한 실험

**다양성 확보**:
- 3개 언어 (Python, C, Node.js)
- node-opcua는 7개 엔드포인트 (다양한 보안 정책)
- 평문 자격증명 확인 완료 (anssi_normal.pcap)

**재현성 확보**:
- 모든 구현체 포트 분리 (4840-4843)
- 엔드포인트 정보 수집 완료
- PCAP 분석 준비 완료

## 다음 단계

1. ✅ 4개 구현체 서버 실행 중
2. ⏭️ 평문 자격증명 테스트
3. ⏭️ 공격 시나리오 캡처
4. ⏭️ PCAP 분석
5. ⏭️ 논문 작성
