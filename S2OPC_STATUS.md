# S2OPC 빌드 상태

## 성공
- ✅ S2OPC GitLab에서 클론 완료: https://gitlab.com/systerel/S2OPC
- ✅ Apache 2.0 라이선스 (오픈소스)
- ✅ Systerel에서 개발

## 문제
- ❌ 빌드 시 `check` 라이브러리 의존성 필요
- ❌ 테스트 코드가 CMake에 포함되어 있어 빌드 실패

## 현재 상태
S2OPC는 테스트 프레임워크 의존성 문제로 현재 환경에서 빌드 어려움

## 해결 방법
다음 중 하나:
1. libcheck-dev 패키지 설치 후 재빌드
2. Docker를 사용한 빌드 (.build-in-docker.sh 스크립트 사용)
3. 샘플 서버만 빌드 (라이브러리는 제외)

## 우선순위
현재 5개 구현체가 모두 작동하므로 S2OPC는 나중에 추가 가능

다음 단계: 5개 구현체로 ANSSI 시나리오 재현
