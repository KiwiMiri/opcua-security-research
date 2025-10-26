#!/bin/bash
# 빠른 검증 및 진단 스크립트

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"

echo "============================================"
echo "빠른 검증 및 진단"
echo "============================================"
echo ""

# 1. PCAP 파일 존재 확인
echo "[1] PCAP 파일 확인..."
if ls "${PCAP_DIR}"/*.pcap 1> /dev/null 2>&1; then
    echo "✅ PCAP 파일 존재"
    ls -lh "${PCAP_DIR}"/*.pcap
else
    echo "❌ PCAP 파일 없음"
fi

echo ""
echo "[2] OpenSecureChannel SecurityPolicy 요약..."

# 각 PCAP 파일에서 SecurityPolicy 추출
for f in "${PCAP_DIR}"/*_{normal,attack}.pcap; do
    if [ -f "$f" ]; then
        base=$(basename "$f")
        echo ""
        echo "--- $base ---"
        tshark -r "$f" -Y "opcua.OpenSecureChannel" \
            -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri \
            2>/dev/null | head -5 || echo "  (데이터 없음)"
    fi
done

echo ""
echo "[3] ActivateSession에서 credential 관련 프레임 찾기..."

for f in "${PCAP_DIR}"/*_attack.pcap; do
    if [ -f "$f" ]; then
        base=$(basename "$f")
        echo ""
        echo "--- $base (공격) ---"
        tshark -r "$f" -Y 'frame contains "UserNameIdentityToken" || frame contains "password" || frame contains "username"' \
            -T fields -e frame.number \
            2>/dev/null | head -10 || echo "  (데이터 없음)"
    fi
done

echo ""
echo "============================================"
echo "검증 완료"
echo "============================================"
