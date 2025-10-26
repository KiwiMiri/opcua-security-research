# Offered Endpoints - 최종 수집 결과

## 실행 중인 서버: 4개

### 1. python-opcua (Port 4840)
**Offered Endpoints:**
- NoSecurity/None (SecurityMode: 1)
- 1개 엔드포인트
- UserIdentityTokens: 1 token

### 2. open62541 (Port 4841)
**Offered Endpoints:**
- NoSecurity/None (SecurityMode: 1)
- 1개 엔드포인트
- UserIdentityTokens: 1 token

### 3. node-opcua (Port 4842) ⭐ 가장 다양한 보안 정책 제공
**Offered Endpoints (7개):**
1. NoSecurity/None (SecurityMode: 1)
2. Basic256Sha256/Sign (SecurityMode: 2)
3. Aes128_Sha256_RsaOaep/Sign (SecurityMode: 2)
4. Aes256_Sha256_RsaPss/Sign (SecurityMode: 2)
5. Basic256Sha256/SignAndEncrypt (SecurityMode: 3)
6. Aes128_Sha256_RsaOaep/SignAndEncrypt (SecurityMode: 3)
7. Aes256_Sha256_RsaPss/SignAndEncrypt (SecurityMode: 3)

### 4. freeopcua (Port 4843)
**Offered Endpoints:**
- NoSecurity/None (SecurityMode: 1)
- 1개 엔드포인트
- UserIdentityTokens: 3 tokens

## 연결 실패

### eclipse-milo (Port 4844)
- 서버 프로세스 실행 중이나 연결 거부됨
- 포트 리스닝 확인 필요

## SecurityMode 값 참고

- `1` = None (NoSecurity)
- `2` = Sign (서명만)
- `3` = SignAndEncrypt (서명 및 암호화)

## 논문용 데이터

**표 형식으로 정리하면:**

| Implementation | Offered Endpoints |
|----------------|-------------------|
| python-opcua   | NoSecurity/None |
| open62541      | NoSecurity/None |
| node-opcua     | NoSecurity/None, Basic256Sha256/Sign, Basic256Sha256/SignAndEncrypt, Aes128_Sha256_RsaOaep/Sign, Aes128_Sha256_RsaOaep/SignAndEncrypt, Aes256_Sha256_RsaPss/Sign, Aes256_Sha256_RsaPss/SignAndEncrypt |
| freeopcua      | NoSecurity/None |
| eclipse-milo   | N/A (연결 실패) |

## 파일 저장 위치

- `endpoints_info.json` - 상세 JSON 데이터
- `endpoints_collection_output.txt` - 수집 로그
