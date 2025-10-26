# ANSSI 시나리오 - 핵심 발견

## 검증 결과

### 1. python-opcua 라이브러리 동작
✅ **서버**: SignAndEncrypt + None 엔드포인트 제공 가능
❌ **클라이언트**: UserNameIdentityToken 사용 시 **평문 전송**

### 2. PCAP 분석 결과
```bash
strings test_signenc.pcap | grep -iE "testuser|password"
```

출력:
```
username
username
username
testuser              # ← 평문으로 전송됨!
password123!          # ← 평문으로 전송됨!
```

### 3. 로그 확인
```
WARNING:opcua.client.client:Sending plain-text password
```

## 핵심 발견

**python-opcua 라이브러리는 SignAndEncrypt 정책을 설정했더라도, 
UserNameIdentityToken의 자격증명을 평문으로 전송합니다.**

이는 다음을 의미합니다:
1. ✅ ANSSI 시나리오의 "평문 자격증명 노출" 부분은 재현 가능
2. ❌ 하지만 "정상 상태에서는 암호화되어 있고, 다운그레이드 시 평문"이라는 가설은 검증 불가
3. 🔴 **python-opcua는 자격증명을 항상 평문으로 전송**

## 결론

현재 측정된 데이터는:
- `user_identity_type_normal`: Anonymous 또는 UserNameIdentityToken
- `username_observed`: testuser (평문)
- `password_observed`: password123! (평문)

이것은 **ANSSI 시나리오와는 다릅니다**:
- ANSSI 요구: 정상 = 암호화, 공격 = 평문
- 현재: 모든 경우 = 평문

## 권장 조치

1. 다른 구현체(Node.js, C)에서 동일 테스트 수행
2. python-opcua의 보안 정책 강제 방법 재검토
3. 실제 인증서 기반 암호화가 동작하는지 확인
4. 라이브러리 버전/설정 문서 재검토

## 파일 위치
- 서버: `servers/python/opcua_server_cert_based.py`
- 클라이언트: `clients/python_client_signenc_forced.py`
- PCAP: `pcaps/test_signenc.pcap`
