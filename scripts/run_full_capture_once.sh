#!/usr/bin/env bash
set -euo pipefail

PCAPS_DIR=/root/opcua-research/pcaps
mkdir -p "$PCAPS_DIR"

# 캡처 파일명 (타임스탬프 포함)
OUT="$PCAPS_DIR/auto_capture_$(date +%Y%m%d_%H%M%S).pcap"

echo "==========================================="
echo "OPC UA 통합 캡처 시작"
echo "파일: $OUT"
echo "==========================================="

# 현재 서버 상태 확인
echo ""
echo "현재 서버 상태:"
ss -tunlp | egrep '4840|4841|4842|4843|4844' || echo "  (서버 없음)"

# 캡처 시작 (60초 제한)
echo ""
echo "tcpdump 캡처 시작 (60초)..."
PORTS="tcp port 4840 or tcp port 4841 or tcp port 4842 or tcp port 4843 or tcp port 4844"
sudo timeout 60 tcpdump -i any -s 0 -w "$OUT" "$PORTS" &
TCPD_PID=$!
sleep 2

# 클라이언트 실행
echo ""
echo "클라이언트 실행 중..."
echo ""

# Python 서버 테스트
echo "[1] Python 클라이언트..."
bash scripts/clients/python_client.sh 2>&1 | sed 's/^/  /' || true

sleep 2

# Node.js 서버 테스트
echo "[2] Node.js 클라이언트..."
bash scripts/clients/node_client.sh 2>&1 | sed 's/^/  /' || true

# 추가 대기 시간
sleep 5

# 캡처 대기
echo ""
echo "캡처 완료 대기 중..."
wait $TCPD_PID || true

# 결과 확인
echo ""
echo "==========================================="
echo "캡처 완료: $OUT"
echo "==========================================="

# 파일 크기
SIZE=$(stat -f%z "$OUT" 2>/dev/null || stat -c%s "$OUT" 2>/dev/null || echo 0)
echo "파일 크기: $SIZE bytes"

if [ "$SIZE" -lt 100 ]; then
    echo ""
    echo "⚠️  경고: 파일이 비어있거나 너무 작습니다 ($SIZE bytes)"
    echo "  - 서버가 실행 중이 아닐 수 있습니다"
    echo "  - 클라이언트 연결이 실패했을 수 있습니다"
else
    echo ""
    echo "✅ 파일 크기 정상"
    
    # 프로토콜 통계
    echo ""
    echo "프로토콜 통계:"
    tshark -r "$OUT" -q -z io,phs 2>/dev/null || echo "  (tshark 분석 실패)"
    
    # 패킷 카운트
    echo ""
    COUNT=$(tshark -r "$OUT" -q -z conv,tcp 2>/dev/null | wc -l || echo 0)
    echo "감지된 패킷: $COUNT"
    
    # OPC UA 메시지 검색
    echo ""
    echo "OPC UA 메시지 검색:"
    tshark -r "$OUT" -Y "opcua" -T fields -e frame.number 2>/dev/null | head -5 || echo "  (OPC UA 메시지 없음)"
fi

echo ""
echo "분석 명령:"
echo "  tshark -r $OUT"
echo "  tshark -r $OUT -Y 'opcua.OpenSecureChannel'"
