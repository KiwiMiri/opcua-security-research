# Eclipse Milo - 최종 결정

## 문제 요약
Milo 0.6.9에서 EndpointConfiguration을 설정했지만 포트 4844 리스닝 실패

## 시도한 내용
1. ✅ stack-server 0.6.9 의존성 추가
2. ✅ EndpointConfiguration.newBuilder() 사용
3. ✅ setBindPort(4844), setBindAddress("0.0.0.0")
4. ✅ startup().get() 완료 대기
5. ❌ UaTransportProfile.TCP_UASC_UABINARY - 클래스 미존재
6. ❌ UserTokenPolicy.ANONYMOUS - 클래스 미존재

## API 버전 문제
Milo 0.6.9에는 다음이 없음:
- `UaTransportProfile` 클래스
- `UserTokenPolicy.ANONYMOUS`
- 기타 엔드포인트 설정 관련 일부 API

이는 0.7.x 이후 버전에서 추가된 기능으로 보임.

## 최종 결정
Eclipse Milo는 실험에서 제외하고, 4개 구현체로 진행:
- python-opcua (4840)
- open62541 (4841)
- node-opcua (4842, 7개 엔드포인트)
- freeopcua (4843)

## 논문 서술
> "Eclipse Milo encountered configuration issues in version 0.6.9 related to endpoint binding API limitations. The required classes for proper endpoint configuration (UaTransportProfile, UserTokenPolicy) were unavailable in this version, preventing successful TCP socket binding. This was documented as a limitation, and our final experimental setup utilized the four working implementations."
