# S2OPC TCP 모드 설정 요약

## 현재 상태

**목표**: S2OPC 서버를 TCP Client/Server 모드로 포트 4845에서 실행

**문제**: 인증서 경로 문제로 서버 기동 실패

## 완료된 작업

1. ✅ 인증서 생성: `build/bin/certs/server_2k_cert.der`, `server_2k_key_encrypted.pem`
2. ✅ 설정 파일 수정: 포트 4843 → 4845
3. ❌ 서버 실행: 인증서 로드 실패

## 오류 원인

로그 분석:
```
Failed to load key from path server_private/encrypted_server_2k_key.pem
```

**원인**: S2OPC가 설정 파일의 절대 경로를 무시하고 `server_private/` 상대 경로를 사용

## 해결 방안

### 옵션 1: 상대 경로 구조 유지 (권장)
설정 파일 위치에서 `server_private/` 디렉터리 생성:
```bash
cd /root/opcua-research/servers/s2opc/build/bin
mkdir -p server_private server_public
cp certs/server_2k_cert.der server_public/
cp certs/server_2k_key_encrypted.pem server_private/
```

설정 파일 수정:
```xml
<ServerCertificate path="server_public/server_2k_cert.der"/>
<ServerKey path="server_private/server_2k_key_encrypted.pem" encrypted="true"/>
```

### 옵션 2: S2OPC 기본 구조 사용
기존 `server_public/`, `server_private/` 디렉터리의 인증서 활용

## 권장 조치

**현재 우선순위**: 
1. S2OPC는 PubSub 모드로 테스트 (이미 빌드됨)
2. TCP 모드는 별도 이슈로 처리
3. 다른 구현체 (open62541, python-opcua 등) 먼저 완료

## 최종 포트 매핑 (업데이트)

| Implementation  | Port  | Status      | 비고                |
|-----------------|-------|-------------|---------------------|
| python-opcua    | 4840  | ✅ 설정 완료 |                     |
| open62541       | 4841  | ✅ 완료/검증 | ✅ TCP 동작 확인     |
| Node.js opcua   | 4842  | ✅ 설정 완료 |                     |
| FreeOpcUa       | 4843  | ✅ 설정 완료 |                     |
| Eclipse Milo    | 4844  | ✅ 설정 완료 |                     |
| S2OPC           | 4845  | ⚠️  설정함   | 인증서 경로 이슈    |

