#!/bin/bash
# 정상 트래픽 캡처 스크립트
# 각 구현체별로 암호화된 트래픽을 개별 pcap으로 수집

set -e

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"
PID_FILE="${BASE_DIR}/capture_pids.txt"

echo "=== 정상 트래픽 캡처 시작 ==="

# PCAP 디렉토리 생성
mkdir -p "$PCAP_DIR"

# 기존 캡처 프로세스 정리
if [ -f "$PID_FILE" ]; then
    echo "기존 캡처 프로세스 종료 중..."
    while read pid; do
        if [ ! -z "$pid" ]; then
            kill $pid 2>/dev/null || true
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

# 각 구현체별 캡처 시작
echo "Python OPC UA (port 4840) 캡처 시작..."
tcpdump -i any -s 0 -w ${PCAP_DIR}/python_normal.pcap 'tcp port 4840' &
echo $! >> "$PID_FILE"

echo "Node.js OPC UA (port 4841) 캡처 시작..."
tcpdump -i any -s 0 -w ${PCAP_DIR}/node_normal.pcap 'tcp port 4841' &
echo $! >> "$PID_FILE"

echo "open62541 (port 4842) 캡처 시작..."
tcpdump -i any -s 0 -w ${PCAP_DIR}/open62541_normal.pcap 'tcp port 4842' &
echo $! >> "$PID_FILE"

echo "FreeOpcUa (port 4843) 캡처 시작..."
tcpdump -i any -s 0 -w ${PCAP_DIR}/freeopcua_normal.pcap 'tcp port 4843' &
echo $! >> "$PID_FILE"

echo "Eclipse Milo (port 4844) 캡처 시작..."
tcpdump -i any -s 0 -w ${PCAP_DIR}/milo_normal.pcap 'tcp port 4844' &
echo $! >> "$PID_FILE"

echo ""
echo "=== 모든 정상 트래픽 캡처가 시작되었습니다 ==="
echo "PID 파일: $PID_FILE"
echo "PCAP 저장 위치: $PCAP_DIR"
echo ""
echo "캡처를 중지하려면: ./scripts/stop_all_captures.sh"
