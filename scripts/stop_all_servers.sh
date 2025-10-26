#!/bin/bash
cd /root/opcua-research

echo "=== 모든 OPC UA 서버 중지 ==="
if [ -f server_pids.txt ]; then
    while read pid; do
        if [ ! -z "$pid" ]; then
            echo "프로세스 $pid 종료 중..."
            kill $pid 2>/dev/null || true
        fi
    done < server_pids.txt
    rm -f server_pids.txt
fi

# 추가 프로세스 정리
pkill -f "opcua_server.py" 2>/dev/null || true
pkill -f "opcua_server.js" 2>/dev/null || true
pkill -f "examples_server" 2>/dev/null || true

echo "모든 서버가 중지되었습니다."
