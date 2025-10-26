#!/bin/bash
# PCAP 파일 분석 스크립트
# OpenSecureChannel의 SecurityPolicy 비교

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"

echo "=== PCAP 분석 시작 ==="
echo ""

# 각 구현체별로 정상/공격 비교
for impl in python node open62541 freeopcua milo; do
    echo "========================================"
    echo "분석: $impl"
    echo "========================================"
    
    # 정상 캡처 분석
    normal_file="${PCAP_DIR}/${impl}_normal.pcap"
    if [ -f "$normal_file" ]; then
        echo "정상 트래픽:"
        tshark -r "$normal_file" -Y "opcua.OpenSecureChannel" -T fields \
            -e frame.number -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null || \
            echo "  (파일이 없거나 OpenSecureChannel이 없습니다)"
    else
        echo "정상 파일 없음: $normal_file"
    fi
    
    echo ""
    
    # 공격 캡처 분석
    attack_file="${PCAP_DIR}/${impl}_attack.pcap"
    if [ -f "$attack_file" ]; then
        echo "공격 트래픽:"
        tshark -r "$attack_file" -Y "opcua.OpenSecureChannel" -T fields \
            -e frame.number -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null || \
            echo "  (파일이 없거나 OpenSecureChannel이 없습니다)"
    else
        echo "공격 파일 없음: $attack_file"
    fi
    
    echo ""
done

echo "=== PCAP 분석 완료 ==="
