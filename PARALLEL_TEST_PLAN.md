# 병렬 테스트 계획

## 목표
모든 OPC UA 구현체를 동시에 테스트하여 빠르게 결과 확보

## 실행 순서

### 1단계: 전체 자동 실행
```bash
cd /root/opcua-research
./scripts/run_all_implementations.sh
```

### 2단계: 결과 분석
```bash
./scripts/analyze_results.sh
```

### 3단계: 수동 검증 (필요 시)
```bash
# PCAP 파일 확인
ls -lh pcaps/*_test_*.pcap

# 특정 PCAP 분석
tshark -r pcaps/pythonopcua_test_*.pcap -Y "opcua"

# 평문 검색
strings pcaps/pythonopcua_test_*.pcap | grep -i password
```

## 예상 결과
- ✅ pythonopcua: 정상 작동 (이미 확인됨)
- ❓ nodeopcua: 테스트 필요
- ❓ freeopcua: 테스트 필요

## 문제 해결
- 서버가 시작 안 되면: `logs/*_server.log` 확인
- PCAP이 비어있으면: 권한 확인 및 포트 확인
- 클라이언트 연결 실패: 서버 로그 확인
