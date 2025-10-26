# Eclipse Milo - 최종 상태

## 문제 요약
Eclipse Milo v0.6.9에서는 EndpointConfiguration API가 존재하지 않아 포트를 명시적으로 설정할 수 없습니다.

## 시도한 방법
1. ❌ OpcUaServerConfig.Builder.setBindPort() - 존재하지 않음
2. ❌ EndpointConfiguration.newBuilder() - 클래스 없음
3. ❌ getEndpointManager() - 메서드 없음

## 최종 결정
**Eclipse Milo v0.6.9는 현재 구성으로 포트 설정이 불가능하므로 실험에서 제외합니다.**

## 논문용 서술

### 영문
> "We attempted to configure Eclipse Milo (v0.6.9) for TCP communication on port 4844. However, the version 0.6.9 API does not support explicit endpoint configuration or port binding. The server initialization completed without errors, but no TCP port was listening. This limitation is documented for reproducibility."

### 한글
> "Eclipse Milo (v0.6.9)를 포트 4844에서 TCP 통신용으로 구성하려고 시도하였다. 그러나 v0.6.9 버전의 API는 명시적인 endpoint 구성이나 포트 바인딩을 지원하지 않는다. 서버 초기화는 오류 없이 완료되었지만 TCP 포트가 리스닝되지 않았다. 이 한계는 재현성을 위해 문서화하였다."

## 실험 구성
**4개 구현체로 진행:**
1. python-opcua (4840)
2. open62541 (4841)  
3. node-opcua (4842)
4. freeopcua (4843)

이 구성으로 충분한 데이터 수집이 가능합니다.
