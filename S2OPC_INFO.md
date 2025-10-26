# S2OPC 상태

## 문제
- Framagit 저장소는 인증이 필요함
- 공개 GitHub 미러를 찾을 수 없음

## 대안
S2OPC 대신 이미 작동하는 5개 구현체로 ANSSI 시나리오 재현 가능:
1. Python-opcua (4840)
2. Node-opcua (4841)  
3. FreeOpcUa (4842)
4. open62541 (4840)
5. Eclipse Milo (4844)

## S2OPC 정보
- S2OPC는 ANSSI에서 개발한 OPC UA C 구현체
- 표준 OPC UA 스택 구현
- 공개 저장소 접근 제한이 있을 수 있음
- 문서나 릴리즈 바이너리를 직접 다운로드하는 방법 고려 필요

## 결론
현재 5개 구현체로도 충분히 실험 가능하며, S2OPC는 나중에 추가 가능
