# 최종 구현체 상태 - 완전한 문서

## ✅ 성공한 구현체 (4개)

| Implementation | Port | Status | Offered Endpoints |
|----------------|------|--------|-------------------|
| **python-opcua** | 4840 | ✅ 실행 중 | NoSecurity/None |
| **open62541** | 4841 | ✅ 실행 중 | NoSecurity/None |
| **node-opcua** | 4842 | ✅ 실행 중 | 7개 엔드포인트 (다양한 보안 정책) |
| **freeopcua** | 4843 | ✅ 실행 중 | NoSecurity/None |

## ❌ 실패한 구현체 (2개)

### Eclipse Milo
- **버전**: 0.6.9
- **문제**: EndpointConfiguration API 추가 후에도 포트 리스닝 실패
- **원인**: 의존성 버전 불일치 또는 API 구성 문제
- **결정**: 실험에서 제외

### S2OPC
- **버전**: commit 2554226f9
- **문제**: PKI 설정 복잡도
- **결정**: PubSub 전용 (TCP 모드 실패)

## 📊 엔드포인트 상세

### node-opcua - 가장 다양함 ⭐
7개 엔드포인트 제공:
1. NoSecurity/None
2. Basic256Sha256/Sign
3. Aes128_Sha256_RsaOaep/Sign
4. Aes256_Sha256_RsaPss/Sign
5. Basic256Sha256/SignAndEncrypt
6. Aes128_Sha256_RsaOaep/SignAndEncrypt
7. Aes256_Sha256_RsaPss/SignAndEncrypt

### 나머지 구현체
- python-opcua: NoSecurity/None
- open62541: NoSecurity/None
- freeopcua: NoSecurity/None

## 📝 논문용 서술

### 영문
> "We evaluated six OPC UA implementations across multiple programming languages. Four implementations (python-opcua, open62541, node-opcua, and freeopcua) were successfully configured for TCP client/server communication on distinct ports (4840-4843). node-opcua provided the most diverse security configurations with 7 endpoints including various encryption modes. Eclipse Milo encountered configuration issues related to endpoint setup, and S2OPC, primarily designed for PubSub communication, required complex PKI configuration for TCP mode. Both were documented as limitations in our experimental setup."

### 한글
> "여섯 개의 OPC UA 구현체를 다양한 프로그래밍 언어로 평가하였다. 4개 구현체(python-opcua, open62541, node-opcua, freeopcua)를 별도 포트(4840-4843)에서 TCP 클라이언트/서버 통신용으로 성공적으로 설정하였다. node-opcua는 다양한 암호화 모드를 포함한 7개 엔드포인트로 가장 다양한 보안 구성을 제공하였다. Eclipse Milo는 endpoint 설정 관련 구성 문제가 있었고, S2OPC는 PubSub 통신용으로 설계되어 TCP 모드에 복잡한 PKI 설정이 필요하였다. 두 구현체는 실험 설정의 한계로 문서화하였다."

## 🎯 실험 준비 완료

**4개 구현체로 충분한 실험 가능**
- 각 구현체별 서버 실행 중
- 엔드포인트 정보 수집 완료
- PCAP 분석 준비
- 평문 자격증명 확인 (anssi_normal.pcap)
