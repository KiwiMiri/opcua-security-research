#!/bin/bash
# PCAP 분석 및 요약 보고서 생성

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "OPC UA PCAP 분석"
echo "=========================================="

mkdir -p reports

for pcap in pcaps/*_test_*.pcap; do
    if [ ! -f "$pcap" ]; then
        echo "⚠️ PCAP 파일 없음: $pcap"
        continue
    fi
    
    filename=$(basename "$pcap" .pcap)
    impl_name=$(echo "$filename" | cut -d'_' -f1)
    
    echo ""
    echo "분석 중: $impl_name"
    echo "파일: $pcap"
    
    # 파일 크기
    SIZE=$(stat -f%z "$pcap" 2>/dev/null || stat -c%s "$pcap")
    echo "  크기: $SIZE bytes"
    
    # OpenSecureChannel 메시지 확인
    echo "  OpenSecureChannel 프레임:"
    tshark -r "$pcap" -Y "opcua.OpenSecureChannel" -T fields \
        -e frame.number \
        -e frame.time \
        -e opcua.opensecurechannel.securitypolicyuri 2>/dev/null | head -5 || echo "    없음"
    
    # ActivateSession 메시지 확인
    echo "  ActivateSession 프레임:"
    tshark -r "$pcap" -Y "opcua.ActivateSession" -T fields \
        -e frame.number 2>/dev/null | head -3 || echo "    없음"
    
    # 평문 검색
    echo "  평문 검색 (password/testuser):"
    strings "$pcap" 2>/dev/null | grep -E "password|testuser" | head -3 || echo "    없음"
done

echo ""
echo "=========================================="
echo "요약 보고서 생성"
echo "=========================================="

cat > reports/summary.txt << SUMMARY
# OPC UA 구현체 테스트 요약

생성 시간: $(date)

## 테스트된 구현체
$(for pcap in pcaps/*_test_*.pcap; do basename "$pcap" .pcap; done)

## PCAP 파일
$(ls -lh pcaps/*_test_*.pcap 2>/dev/null || echo "없음")

## 서버 로그
$(ls -lh logs/*_server.log 2>/dev/null || echo "없음")

## 다음 단계
1. pcaps/ 디렉토리에서 각 PCAP 확인
2. tshark로 프레임 분석: tshark -r pcaps/<file>.pcap -Y "opcua"
3. 평문 검색: strings pcaps/<file>.pcap | grep -i password

SUMMARY

cat reports/summary.txt
