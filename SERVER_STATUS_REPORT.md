# OPC UA 서버 실행 상태 보고

## ✅ 현재 실행 중인 서버 (4개)

| Implementation | Port | Status | Offered Endpoints |
|----------------|------|--------|-------------------|
| **python-opcua** | 4840 | ✅ 실행 중 | NoSecurity/None (1) |
| **open62541** | 4841 | ✅ 실행 중 | NoSecurity/None (1) |
| **node-opcua** | 4842 | ✅ 실행 중 | NoSecurity/None, Basic256Sha256/Sign, Basic256Sha256/SignAndEncrypt, Aes128_Sha256_RsaOaep/Sign, Aes128_Sha256_RsaOaep/SignAndEncrypt, Aes256_Sha256_RsaPss/Sign, Aes256_Sha256_RsaPss/SignAndEncrypt (7) |
| **freeopcua** | 4843 | ✅ 실행 중 | NoSecurity/None (1) |

## ⚠️ 실행되지 않는 서버 (2개)

| Implementation | Port | Status | 원인 |
|----------------|------|--------|------|
| **eclipse-milo** | 4844 | ❌ 연결 실패 | 포트 리스닝 안 됨 (로그 확인 필요) |
| **S2OPC** | 4845 | ❌ N/A | PubSub 전용 (TCP 모드 실패) |

## 📊 엔드포인트 상세 정보

### python-opcua (port 4840)
- SecurityMode: 1 (None)
- SecurityPolicyUri: http://opcfoundation.org/UA/SecurityPolicy#None
- UserIdentityTokens: 1 token

### open62541 (port 4841)
- SecurityMode: 1 (None)
- SecurityPolicyUri: http://opcfoundation.org/UA/SecurityPolicy#None
- UserIdentityTokens: 1 token

### node-opcua (port 4842)
7개 엔드포인트 제공:
1. NoSecurity/None (Mode 1)
2. Basic256Sha256/Sign (Mode 2)
3. Aes128_Sha256_RsaOaep/Sign (Mode 2)
4. Aes256_Sha256_RsaPss/Sign (Mode 2)
5. Basic256Sha256/SignAndEncrypt (Mode 3)
6. Aes128_Sha256_RsaOaep/SignAndEncrypt (Mode 3)
7. Aes256_Sha256_RsaPss/SignAndEncrypt (Mode 3)

### freeopcua (port 4843)
- SecurityMode: 1 (None)
- SecurityPolicyUri: http://opcfoundation.org/UA/SecurityPolicy#None
- UserIdentityTokens: 3 tokens

## 💡 SecurityMode 값 해석

- `1` = None (NoSecurity)
- `2` = Sign (서명만)
- `3` = SignAndEncrypt (서명 및 암호화)

## 🎯 실험 준비 완료

**4개 구현체가 정상 실행 중이며, 엔드포인트 정보 수집 완료**

다음 단계:
1. PCAP 캡처 (normal/attack)
2. Plaintext credential 확인
3. 결과 분석
