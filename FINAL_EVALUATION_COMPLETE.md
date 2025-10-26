# OPC UA 구현체 평가 - 최종 완료

## ✅ 성공한 구현체 (4개)

1. **python-opcua** (Python, 4840)
2. **open62541** (C, 4841)
3. **node-opcua** (Node.js, 4842) - 7개 엔드포인트 ⭐
4. **freeopcua** (Python, 4843)

## ❌ 제외된 구현체 (2개)

### Eclipse Milo
- **문제**: 
  - 0.6.9: endpoint binding API 부족
  - 1.0.6: Maven 의존성 복잡도로 인한 빌드 실패
  - 예제 빌드 시 MoreObjects 등 Guava 의존성 오류
- **결정**: 실험에서 제외

### S2OPC
- **문제**: PKI 설정 복잡도
- **결정**: PubSub 전용 (TCP 모드 설정 어려움)

## 결론

**4개 구현체로 충분한 실험 가능**
- 3개 프로그래밍 언어 (Python, C, Node.js)
- 모든 서버 실행 중 (4840-4843)
- 평문 자격증명 확인 완료
- PCAP 분석 준비 완료

## 논문 서술

> "We evaluated six OPC UA implementations. Four implementations (python-opcua, open62541, node-opcua, and freeopcua) were successfully configured for TCP client/server communication on distinct ports (4840-4843). Eclipse Milo encountered configuration issues: version 0.6.9 lacked necessary API classes, and version 1.0.6 had complex Maven dependency issues that prevented successful compilation. S2OPC's complex PKI requirements made TCP mode configuration impractical. Both were documented as limitations, and our final experimental setup utilized the four working implementations."
