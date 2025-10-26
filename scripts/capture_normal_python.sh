#!/usr/bin/env bash
set -e

PCAP_DIR="/root/opcua-research/pcaps"
PCAP="${PCAP_DIR}/python_normal_$(date +%Y%m%d_%H%M%S).pcap"

mkdir -p "$PCAP_DIR"

echo "========================================"
echo "정상 트래픽 캡처 시작"
echo "파일: $PCAP"
echo "========================================"

# 캡처 시작
sudo timeout 30 tcpdump -i any -s 0 -w "$PCAP" "tcp port 4840" &
TCPD=$!
sleep 1

echo "클라이언트 실행 중..."
cd /root/opcua-research
source venv/bin/activate
python3 clients/python_client_username.py

sleep 1

wait $TCPD || true

echo ""
echo "========================================"
echo "캡처 완료: $PCAP"
echo "========================================"

# 파일 크기 확인
SIZE=$(stat -c%s "$PCAP" 2>/dev/null || echo 0)
echo "파일 크기: $SIZE bytes"

# OpenSecureChannel 분석
echo ""
echo "OpenSecureChannel SecurityPolicy:"
tshark -r "$PCAP" -Y "opcua.OpenSecureChannel" -T fields \
    -e frame.number -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null || echo "데이터 없음"

echo ""
echo "분석:"
echo "  tshark -r $PCAP -Y 'opcua'"
echo "  tshark -r $PCAP -Y 'frame.number == 14' -V | grep -i password"
