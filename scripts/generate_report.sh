#!/bin/bash
# 분석 보고서 생성 스크립트
# CSV 형태로 SecurityPolicy 비교

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"
REPORT_DIR="${BASE_DIR}/reports"

mkdir -p "$REPORT_DIR"

echo "=== 분석 보고서 생성 중 ==="

# 각 구현체별 OpenSecureChannel 정책 추출
for impl in python node open62541 freeopcua milo; do
    # 정상 캡처
    if [ -f "${PCAP_DIR}/${impl}_normal.pcap" ]; then
        tshark -r "${PCAP_DIR}/${impl}_normal.pcap" \
            -Y "opcua.OpenSecureChannel" \
            -T fields -e frame.number -e frame.time -e opcua.opensecurechannel.securitypolicyuri \
            > "${REPORT_DIR}/${impl}_normal.csv" 2>/dev/null
    fi
    
    # 공격 캡처
    if [ -f "${PCAP_DIR}/${impl}_attack.pcap" ]; then
        tshark -r "${PCAP_DIR}/${impl}_attack.pcap" \
            -Y "opcua.OpenSecureChannel" \
            -T fields -e frame.number -e frame.time -e opcua.opensecurechannel.securitypolicyuri \
            > "${REPORT_DIR}/${impl}_attack.csv" 2>/dev/null
    fi
done

echo "보고서 생성 완료: $REPORT_DIR"
echo ""
echo "생성된 파일:"
ls -lh "$REPORT_DIR"/*.csv
