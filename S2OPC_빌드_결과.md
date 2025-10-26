# S2OPC v1.4.0 빌드 결과

## 빌드 정보

**버전**: S2OPC v1.4.0  
**날짜**: 2025-10-22  
**빌드 상태**: ✅ 성공 (라이브러리만)

## 빌드 과정

```bash
cd /root/opcua-research/S2OPC-1.4.0
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## 빌드된 컴포넌트

### 라이브러리
- `s2opc_common` - 공통 라이브러리
- `s2opc_clientserver` - 클라이언트/서버 라이브러리  
- `s2opc_clientwrapper` - 클라이언트 래퍼
- `s2opc_serverwrapper` - 서버 래퍼

### 클라이언트 도구
- `s2opc_read` - 읽기 클라이언트
- `s2opc_write` - 쓰기 클라이언트
- `s2opc_browse` - 브라우즈 클라이언트
- `s2opc_discovery` - 디스커버리 클라이언트
- `s2opc_findserver` - 서버 찾기
- `s2opc_register` - 서버 등록
- `s2opc_subscription_client` - 구독 클라이언트
- `S2OPC_CLI_Client` - CLI 클라이언트

### 기타
- `bench_tool` - 벤치마크 도구

## 빌드되지 않은 항목

### Demo 서버
```
CMake Warning: Demo server toolkit_demo_server executable will not be compiled 
since Expat library not available.
```

**원인**: Expat XML 파서 라이브러리 누락

## S2OPC 특징

### 보안 정책 지원
README에 명시된 지원 정책:
- SecurityPolicy#None
- SecurityPolicy#Basic256  
- SecurityPolicy#Basic256Sha256

### OPC Foundation 인증
- Nano Embedded Device Server
- SecurityPolicy - Basic256
- SecurityPolicy - Basic256Sha256
- User Token - Anonymous Facet
- User Token - User Name Password Server Facet

## 비교: S2OPC vs open62541

| 항목 | S2OPC v1.4.0 | open62541 v1.3.8 |
|------|-------------|------------------|
| 빌드 크기 | 라이브러리만 | 단일 실행파일 (974KB) |
| 빌드 복잡도 | 높음 (여러 의존성) | 낮음 (amalgamation) |
| 간단한 서버 | ❌ Expat 필요 | ✅ 바로 실행 가능 |
| 인증 | OPC Foundation 인증 | 커뮤니티 구현 |
| 보안 강도 | 강함 (formal methods) | 표준 |

## Expat 설치 후 재빌드

### Expat 설치
```bash
sudo apt-get install libexpat1-dev
```

### 재빌드
```bash
cd /root/opcua-research/S2OPC-1.4.0/build
rm -rf *
cmake ..
make -j$(nproc)
```

## 실험 목적의 결론

**S2OPC는 복잡도가 높아 실험용으로는 open62541이 더 적합합니다.**

이유:
1. open62541: 단일 실행 파일, 즉시 테스트 가능
2. S2OPC: 라이브러리만 빌드됨, XML 설정 파일 필요
3. 보안 취약점 테스트에는 open62541로 충분

## 실제 구현체 확인

✅ **open62541 v1.3.8** - 실제 C 구현, 실행 완료, SecurityPolicy#None 확인  
⚠️ **S2OPC v1.4.0** - 라이브러리 빌드 성공, 데모 서버 미포함

## 다음 단계

1. **Expat 설치 후 S2OPC demo server 빌드 시도** (선택사항)
2. **또는 open62541 결과로 논문 작성** (권장)

현재 open62541 v1.3.8 실제 C 서버로 충분한 실험 데이터 확보됨.

