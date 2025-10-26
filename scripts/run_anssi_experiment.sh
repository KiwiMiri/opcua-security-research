#!/bin/bash
# ANSSI 시나리오 자동 실행 스크립트

set -e

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"

mkdir -p "$PCAP_DIR"

echo "=========================================="
echo "ANSSI 시나리오 재현 실험"
echo "=========================================="
echo ""

# 1. 기존 서버 종료
echo "[1/5] 기존 서버 종료..."
pkill -f "python.*opcua" || true
sleep 1

# 2. ANSSI 서버 시작
echo "[2/5] ANSSI 서버 시작 (암호화 + None)..."
cd "$BASE_DIR"
source venv/bin/activate
python3 servers/python/opcua_server_anssi.py > logs/anssi_server.log 2>&1 &
SERVER_PID=$!
echo "서버 PID: $SERVER_PID"
sleep 2

# 3. 정상 캡처 (SignAndEncrypt)
echo ""
echo "[3/5] 정상 캡처 (SignAndEncrypt)..."
sudo timeout 30 tcpdump -i any -s 0 -w "${PCAP_DIR}/anssi_normal.pcap" 'tcp port 4840' &
sleep 1
python3 clients/python_client_username_encrypted.py
wait
echo "정상 캡처 완료"

# 4. 공격 캡처 (다운그레이드 - 클라이언트가 NoSecurity 선택)
echo ""
echo "[4/5] 공격 캡처 (NoSecurity)..."
sudo timeout 30 tcpdump -i any -s 0 -w "${PCAP_DIR}/anssi_attack.pcap" 'tcp port 4840' &
sleep 1
python3 clients/python_client_username.py  # 기존 클라이언트는 NoSecurity 사용
wait
echo "공격 캡처 완료"

# 5. 분석
echo ""
echo "[5/5] 결과 분석..."
echo ""
echo "=== 정상 캡처 ==="
ls -lh "${PCAP_DIR}/anssi_normal.pcap"
tshark -r "${PCAP_DIR}/anssi_normal.pcap" -Y "opcua.OpenSecureChannel" \
    -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null || echo "분석 실패"

echo ""
echo "=== 공격 캡처 ==="
ls -lh "${PCAP_DIR}/anssi_attack.pcap"
tshark -r "${PCAP_DIR}/anssi_attack.pcap" -Y "opcua.OpenSecureChannel" \
    -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null || echo "분석 실패"

echo ""
echo "평문 검색 (공격):"
strings "${PCAP_DIR}/anssi_attack.pcap" | grep -iE "testuser|password" || echo "평문 없음"

# 서버 종료
kill $SERVER_PID 2>/dev/null || true

echo ""
echo "=========================================="
echo "실험 완료"
echo "=========================================="
