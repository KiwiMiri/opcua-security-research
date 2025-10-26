# 공식 개발자 경고 문서

## 확인된 사실

open62541 개발자가 **직접 코드에 작성한 경고문**입니다.

### 소스 위치
- 파일: `open62541/plugins/ua_accesscontrol_default.c`
- 라인: 414, 430

### 경고 문구
```c
if(UA_String_equal(utpUri, &UA_SECURITY_POLICY_NONE_URI)) {
    UA_LOG_WARNING(config->logging, UA_LOGCATEGORY_SERVER,
                   "Username/Password Authentication configured, "
                   "but no encrypting SecurityPolicy. "
                   "This can leak credentials on the network.");
}
```

## 의미

1. **open62541 개발자가 인지한 문제**:
   - Username/Password 인증 + NoSecurity 정책 조합 시
   - **자격증명이 네트워크로 누출될 수 있음**

2. **왜 중요한가?**
   - 우리가 발견한 것이 아니라
   - **라이브러리 개발자가 이미 알고 있었던 문제**
   - 단지 경고만 하고 기본 설정에서 허용함

3. **연구 가치**:
   - 개발자가 알고 있지만 해결하지 않은 문제
   - NoSecurity + UsernamePassword 조합의 위험성
   - 실제 네트워크 패킷에서 평문 확인 가능

## 결론

우리가 찾은 것은 **개발자가 알고 있지만 경고만 하는** 보안 취약점입니다.
이는 더 큰 연구 가치를 의미합니다:
- 공식 라이브러리에서도 발생
- 개발자가 인지했지만 기본 설정 허용
- 실제 PCAP에서 평문 확인 가능
