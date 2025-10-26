# Eclipse Milo 상태

## 현재 상황
- 코드는 정상 컴파일됨
- 서버는 시작되지만 포트 4844에서 리스닝하지 않음
- 로그에는 "Starting on port 4844..." 메시지가 있지만 실제 포트는 열리지 않음

## 원인 분석
Eclipse Milo의 기본 설정 방식에서 포트를 명시적으로 지정하는 방법이 복잡함

## 권장 조치
**eclipse-milo는 현재 4개 서버( python-opcua, open62541, node-opcua, freeopcua)로 충분히 실험 가능**

eclipse-milo는 별도 이슈로 문서화하고, 현재 실행 중인 4개 서버로 실험을 진행하는 것을 권장합니다.

## 논문용 서술
> "Five OPC UA implementations were evaluated, with four (python-opcua, open62541, node-opcua, and freeopcua) successfully configured and tested. Eclipse Milo encountered configuration issues related to endpoint setup and was noted as a limitation in the study."
