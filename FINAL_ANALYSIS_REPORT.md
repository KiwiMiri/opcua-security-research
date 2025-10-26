# OPC UA 실험 - 최종 분석 보고서

## 📊 실행 상태 요약

### ✅ 현재 실행 중인 서버 (4개)

| Implementation | Port | Status | Offered Endpoints |
|----------------|------|--------|-------------------|
| python-opcua   | 4840 | ✅ 실행 중 | NoSecurity/None |
| open62541      | 4841 | ✅ 실행 중 | NoSecurity/None |
| node-opcua     | 4842 | ✅ 실행 중 | 7개 엔드포인트 (다양한 보안 정책) |
| freeopcua      | 4843 | ✅ 실행 중 | NoSecurity/None |

### ❌ 연결 실패

| Implementation | Port | 원인 |
|----------------|------|------|
| eclipse-milo   | 4844 | 프로세스 실행 중이지만 포트 리스닝 안 됨 |

## 🔍 PCAP 분석 결과

### 유효한 PCAP 파일 (3개)
1. `anssi_normal.pcap` - 21 packets, 11 OPC UA messages
2. `python_username_normal.pcap` - 21 packets, 11 OPC UA messages
3. `auto_capture_20251026_014839.pcap` - 46 packets, 11 OPC UA messages

### 발견 사항

**평문 자격증명 노출:**
```bash
strings anssi_normal.pcap
testuser
password123!
```

**보안 정책:**
- 대부분의 구현체: NoSecurity/None만 제공
- node-opcua만 7개 엔드포인트 제공 (Sign, SignAndEncrypt 포함)

## 📋 다음 단계 권장사항

### 1. eclipse-milo 문제 해결
현재 로그에서 한글 인코딩 문제로 인해 일부 메시지가 깨짐.
```bash
# Milo 재시작
cd servers/eclipse-milo/opcua-server
pkill -f "org.eclipse.milo.Server"
mvn clean compile -q
nohup java -cp "target/classes:$(mvn dependency:build-classpath -q -DincludeScope=runtime 2>&1 | grep -v '^\[INFO\]')" org.eclipse.milo.Server > ../../logs/eclipse_milo_server.log 2>&1 &
```

### 2. 체계적인 PCAP 캡처
각 구현체별로:
- **정상 캡처**: 클라이언트가 직접 서버에 연결
- **공격 캡처**: MITM 프록시를 통한 다운그레이드 공격

### 3. 평문 자격증명 확인
`anssi_normal.pcap`에서 이미 평문 자격증명이 확인됨:
- `testuser`
- `password123!`

이는 NoSecurity 모드에서의 정상적인 동작입니다.

## 📄 논문용 데이터

### Offered Endpoints 결과

| Implementation | Offered Endpoints |
|----------------|-------------------|
| python-opcua   | NoSecurity/None |
| open62541      | NoSecurity/None |
| node-opcua     | NoSecurity/None, Basic256Sha256/Sign, Basic256Sha256/SignAndEncrypt, Aes128_Sha256_RsaOaep/Sign, Aes128_Sha256_RsaOaep/SignAndEncrypt, Aes256_Sha256_RsaPss/Sign, Aes256_Sha256_RsaPss/SignAndEncrypt |
| freeopcua      | NoSecurity/None |

### PCAP 분석 결과 (일부)

| 파일명 | 패킷 수 | OPC UA 메시지 | 평문 자격증명 |
|--------|---------|---------------|---------------|
| anssi_normal.pcap | 21 | 11 | ✅ 발견 (testuser/password123!) |
| python_username_normal.pcap | 21 | 11 | - |
| auto_capture_20251026_014839.pcap | 46 | 11 | - |

## ✅ 완료된 작업

1. ✅ 4개 구현체 서버 실행
2. ✅ 엔드포인트 정보 수집 (`endpoints_info.json`)
3. ✅ PCAP 파일 분석 (`pcap_analysis_results.tsv`)
4. ✅ 평문 자격증명 확인 (`anssi_normal.pcap`)

## 🎯 우선순위 작업

1. **즉시**: eclipse-milo 재시작 및 연결 확인
2. **우선**: 각 구현체별 정상/공격 PCAP 캡처
3. **필수**: MITM 프록시 구현 및 다운그레이드 공격 검증
4. **정리**: 모든 결과를 논문용 TSV 형식으로 정리

## 📝 논문용 핵심 문구

> "We evaluated five OPC UA implementations across multiple programming languages. Four implementations (python-opcua, open62541, node-opcua, and freeopcua) were successfully configured for TCP client/server communication on distinct ports (4840-4843). Preliminary analysis of captured network traffic from the ANSSI scenario revealed plaintext credential transmission when NoSecurity mode was used, confirming the vulnerability documented in previous research."
