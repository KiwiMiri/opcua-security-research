#!/bin/bash
# 모든 캡처 프로세스 중지

BASE_DIR="/root/opcua-research"
PID_FILE="${BASE_DIR}/capture_pids.txt"

echo "=== 캡처 프로세스 중지 중 ==="

if [ -f "$PID_FILE" ]; then
    while read pid; do
        if [ ! -z "$pid" ]; then
            echo "캡처 프로세스 $pid 종료 중..."
            kill $pid 2>/dev/null || true
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

# 추가 tcpdump 프로세스 정리
pkill -f "tcpdump.*pcaps" 2>/dev/null || true

echo "모든 캡처 프로세스가 중지되었습니다."
