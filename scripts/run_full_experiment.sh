#!/bin/bash
# 전체 실험 자동 실행 스크립트

set -e

BASE_DIR="/root/opcua-research"

echo "============================================"
echo "OPC UA 구현체 비교 실험 시작"
echo "============================================"
echo ""

# 1. 모든 서버 시작
echo "[1/7] 모든 OPC UA 서버 시작 중..."
cd "$BASE_DIR"
./scripts/start_all_servers.sh
sleep 5

# 2. 서버 상태 확인
echo ""
echo "[2/7] 서버 상태 확인..."
ss -tunlp | egrep '48(40|41|42|43|44)' || netstat -tuln | egrep '48(40|41|42|43|44)'

# 3. 정상 트래픽 캡처
echo ""
echo "[3/7] 정상 트래픽 캡처 시작..."
./scripts/capture_all_normal.sh &
CAPTURE_NORMAL_PID=$!
echo "캡처 PID: $CAPTURE_NORMAL_PID"
echo "30초 대기 중 (클라이언트 연결 시뮬레이션)..."
sleep 30
kill $CAPTURE_NORMAL_PID 2>/dev/null || true
./scripts/stop_all_captures.sh

# 4. 공격 트래픽 캡처
echo ""
echo "[4/7] 공격 트래픽 캡처 시작..."
./scripts/capture_all_attack.sh &
CAPTURE_ATTACK_PID=$!
echo "캡처 PID: $CAPTURE_ATTACK_PID"
echo "30초 대기 중 (다운그레이드 공격 시뮬레이션)..."
sleep 30
kill $CAPTURE_ATTACK_PID 2>/dev/null || true
./scripts/stop_all_captures.sh

# 5. PCAP 파일 확인
echo ""
echo "[5/7] 생성된 PCAP 파일 확인..."
ls -lh pcaps/*.pcap 2>/dev/null || echo "PCAP 파일 없음"

# 6. 자동 분석
echo ""
echo "[6/7] PCAP 파일 자동 분석..."
./scripts/analyze_pcaps.sh

# 7. 보고서 생성
echo ""
echo "[7/7] 분석 보고서 생성..."
./scripts/generate_report.sh

echo ""
echo "============================================"
echo "실험 완료!"
echo "============================================"
echo ""
echo "생성된 파일:"
echo "  - PCAP: pcaps/*.pcap"
echo "  - 보고서: reports/*.csv"
echo ""
echo "상세 분석:"
echo "  ./scripts/analyze_pcaps.sh"
echo "  ./scripts/generate_report.sh"
