# C 구현체 (open62541) 서버 상태

## 확인된 사실

### 서버 로그에서 중요한 메시지

1. **시작 시 경고**:
```
x509 Certificate Authentication configured, but no encrypting SecurityPolicy. 
This can leak credentials on the network.
```

2. **클라이언트 연결 시**:
```
Removing a UserTokenPolicy that would allow the password to be transmitted without encryption
(Can be enabled via config->allowNonePolicyPassword)
```

## 의미

open62541는 **기본적으로 평문 패스워드 전송을 차단**합니다!

하지만:
- 개발자가 이미 이 문제를 인지하고 있음
- 경고 메시지로 알림
- `allowNonePolicyPassword` 설정으로 허용 가능

## 결론

C 구현체는 **기본적으로 안전**하게 설계되어 있습니다.
하지만 개발자가 **알고 있는 취약점**이며, 옵션으로 허용 가능합니다.
