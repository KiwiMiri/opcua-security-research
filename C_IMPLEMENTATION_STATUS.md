# C 구현체 (open62541) 상태

## 상태
- ✅ 서버 빌드 완료
- ✅ 서버 실행 가능
- ⚠️ 테스트 필요

## 서버 로그
```
[2025-10-26 02:54:49.696] AccessControl: Unconfigured AccessControl. Users have all permissions.
[2025-10-26 02:54:49.696] AccessControl: Anonymous login is enabled
[2025-10-26 02:54:49.696] x509 Certificate Authentication configured, but no encrypting SecurityPolicy. This can leak credentials on the network.
```

## 포트
- 4840 (기본 OPC UA 포트)

## 경고
서버 로그에 "This can leak credentials on the network" 경고가 표시됩니다.
이것이 바로 우리가 찾던 증거입니다!

## 다음 단계
1. 클라이언트 연결 테스트
2. PCAP 캡처
3. 평문 자격증명 확인
