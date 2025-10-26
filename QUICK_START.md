# 빠른 실행 가이드

## 🚀 바로 실행하기

### 방법 1: 전체 자동 실행 (권장)
```bash
cd /root/opcua-research
sudo ./scripts/run_full_experiment.sh
```

### 방법 2: 단계별 실행
```bash
# 1. 서버 시작
./scripts/start_all_servers.sh

# 2. 정상 트래픽 캡처 (30초)
sudo ./scripts/capture_all_normal.sh
sleep 30
./scripts/stop_all_captures.sh

# 3. 공격 트래픽 캡처 (30초)
sudo ./scripts/capture_all_attack.sh
sleep 30
./scripts/stop_all_captures.sh

# 4. 분석 및 보고서
./scripts/analyze_pcaps.sh
./scripts/generate_report.sh
```

## 📊 빠른 검증
```bash
# PCAP 파일 확인 및 기본 분석
sudo ./scripts/quick_check.sh
```

## 🔍 상세 분석

### 특정 프레임 덤프
```bash
# 예: node 구현체의 13번 프레임
sudo ./scripts/dump_frame.sh node 13
```

### 자격증명 검색
```bash
./scripts/find_credentials.sh node 13
```

## 📄 논문용 자료 생성

### 캡션 생성
```bash
./scripts/generate_caption.sh node 13 "0x00E0-0x00F0"
```

### 보고서 확인
```bash
cat reports/*.csv
```

## ⚠️ 주의사항

1. **sudo 권한 필요**: tcpdump는 root 권한이 필요합니다
2. **포트 충돌**: 4840~4844 포트가 이미 사용 중이면 서버 시작 실패
3. **클라이언트 연결**: 캡처 중 실제 클라이언트 연결 필요 (시뮬레이션)

## 🎯 다음 단계

실험 실행 후:
1. `pcaps/` 디렉토리의 PCAP 파일 확인
2. `reports/` 디렉토리의 CSV 보고서 확인
3. Wireshark로 PCAP 파일 상세 분석
4. 논문용 캡션 및 인용문 생성

자세한 내용은 `EXPERIMENT_GUIDE.md` 참조
