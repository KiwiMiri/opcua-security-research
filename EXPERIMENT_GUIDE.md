# OPC UA 구현체별 정상 vs 공격 캡처 실험 가이드

## 🎯 목적
각 OPC UA 구현체에서 정상 트래픽(암호화)과 공격 트래픽(다운그레이드)을 캡처하여 보안 취약점을 분석합니다.

## 📋 사전 준비

### 0. 서버 상태 확인
```bash
# 열려있는 포트 확인
ss -tunlp | egrep '48(40|41|42|43|44|45|46|47|48|49)' || \
netstat -tuln | egrep '48(40|41|42|43|44|45|46|47|48|49)'
```

### 1. 모든 서버 시작
```bash
cd /root/opcua-research
./scripts/start_all_servers.sh
```

## 🔬 실험 1: 정상 트래픽 캡처

### 실행
```bash
# 정상 트래픽 캡처 시작
./scripts/capture_all_normal.sh
```

### 예상 결과
- `pcaps/python_normal.pcap` - Python OPC UA 정상 트래픽
- `pcaps/node_normal.pcap` - Node.js OPC UA 정상 트래픽  
- `pcaps/open62541_normal.pcap` - open62541 정상 트래픽
- `pcaps/freeopcua_normal.pcap` - FreeOpcUa 정상 트래픽
- `pcaps/milo_normal.pcap` - Eclipse Milo 정상 트래픽

### 검증
```bash
# 각 pcap 파일에서 SecurityPolicy 확인
tshark -r pcaps/python_normal.pcap -Y "opcua.OpenSecureChannel" \
  -T fields -e opcua.opensecurechannel.securitypolicyuri
```

**예상 결과**: Basic256Sha256 또는 Basic256만 표시 (NoSecurity 없음)

## 🔬 실험 2: 공격 트래픽 캡처

### 실행
```bash
# 공격 트래픽 캡처 시작
./scripts/capture_all_attack.sh
```

### 예상 결과
- `pcaps/python_attack.pcap` - Python OPC UA 공격 트래픽
- `pcaps/node_attack.pcap` - Node.js OPC UA 공격 트래픽
- `pcaps/open62541_attack.pcap` - open62541 공격 트래픽
- `pcaps/freeopcua_attack.pcap` - FreeOpcUa 공격 트래픽
- `pcaps/milo_attack.pcap` - Eclipse Milo 공격 트래픽

### 검증
```bash
# 각 pcap 파일에서 SecurityPolicy 확인
tshark -r pcaps/node_attack.pcap -Y "opcua.OpenSecureChannel" \
  -T fields -e opcua.opensecurechannel.securitypolicyuri
```

**예상 결과**: SecurityPolicy#None 등장 (다운그레이드 성공)

## 📊 분석

### 자동 분석
```bash
# PCAP 자동 분석
./scripts/analyze_pcaps.sh

# 보고서 생성 (CSV)
./scripts/generate_report.sh
```

### 수동 분석
```bash
# 평문 자격증명 찾기 (예: node-opcua, 프레임 13)
./scripts/find_credentials.sh node 13
```

## 📈 논문용 결과 표

### CSV 파일 확인
```bash
# 보고서 확인
cat reports/*.csv
```

### 결과 해석

| 구현체 | 정상 SecurityPolicy | 공격 SecurityPolicy | 평문 노출 |
|--------|-------------------|-------------------|-----------|
| python | Basic256Sha256 | None | Yes |
| node | Basic256Sha256 | None | Yes |
| open62541 | Basic256Sha256 | None | Yes |
| freeopcua | Basic256Sha256 | None | Yes |
| milo | Basic256Sha256 | None | Yes |

## 🎓 논문용 문장 템플릿

### 한글 버전
"각 구현체(python-opcua, open62541, node-opcua, FreeOpcUa, Eclipse Milo)에 대해 정상(암호화-only) 와 공격(강제 다운그레이드) 트래픽을 개별 pcap으로 수집하였다. 정상 캡처에서는 ActivateSession의 UserNameIdentityToken이 암호화된 blob으로만 관찰되었으나, 공격 캡처에서는 SecurityPolicy가 None으로 전환된 이후 동일 필드에서 평문 자격증명(Username/Password) 이 관찰되었다(예: node-opcua/Frame 13, ASCII 0x00E0–0x00F0)."

### 영어 버전
"For each implementation (python-opcua, open62541, node-opcua, FreeOpcUa, Eclipse Milo), we captured both baseline (encrypted-only) and attack (forced downgrade) traces. In baseline captures, the ActivateSession UserNameIdentityToken appeared as an encrypted blob; after the downgrade to SecurityPolicy=None, the same field revealed plaintext credentials (e.g., node-opcua/Frame 13, ASCII 0x00E0–0x00F0)."

## ⚠️ 주의사항

1. **정상 캡처에 NoSecurity 섞기 금지** → 정상은 Basic256Sha256 only
2. **포트 혼동 금지** → 구현체별 고정 포트 (4840~4844)
3. **캡처 시작 타이밍** → Hello/OpenSecureChannel부터 잡기
4. **라이브러리별 상이함** → 각 구현체별 정상/공격 pcap 세트 확보
5. **tshark 필터 빈출력** → 디섹터 활성화/Decode As로 포트를 OPC UA 지정

## 🛠️ 트러블슈팅

### Protocol Hierarchy가 tcp → data만 보이는 경우
- Analyze > Enabled Protocols에서 OPC UA 활성화
- Decode As로 포트를 OPC UA로 지정

### TLS 복호화 필요
- RSA 키 교환: 서버 키로 가능
- ECDHE: SSLKEYLOGFILE로 키로그 파일 생성

### 정상 캡처에 평문이 보이는 경우
- 정상 서버에서 NoSecurity가 섞여 있는지 설정 재점검

## 📁 생성되는 파일 구조

```
/root/opcua-research/
├── pcaps/                      # 캡처 파일
│   ├── python_normal.pcap     # Python 정상
│   ├── python_attack.pcap     # Python 공격
│   ├── node_normal.pcap       # Node.js 정상
│   ├── node_attack.pcap       # Node.js 공격
│   └── ...
├── reports/                    # 분석 보고서 (CSV)
│   ├── python_normal.csv
│   ├── python_attack.csv
│   └── ...
└── scripts/                    # 실행 스크립트
    ├── capture_all_normal.sh
    ├── capture_all_attack.sh
    ├── analyze_pcaps.sh
    ├── find_credentials.sh
    └── generate_report.sh
```

## 🚀 빠른 시작 요약

```bash
# 1. 서버 시작
./scripts/start_all_servers.sh

# 2. 정상 트래픽 캡처
./scripts/capture_all_normal.sh

# 3. 공격 트래픽 캡처 (별도 터미널에서)
./scripts/capture_all_attack.sh

# 4. 분석
./scripts/analyze_pcaps.sh
./scripts/generate_report.sh

# 5. 결과 확인
cat reports/*.csv
```

## 📞 도움말

문제가 발생하면:
1. 서버 상태 확인: `netstat -tlnp | grep 484`
2. 로그 확인: `tail -f logs/*.log`
3. 캡처 프로세스 확인: `ps aux | grep tcpdump`

