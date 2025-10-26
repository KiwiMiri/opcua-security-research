#!/bin/bash
# S2OPC PubSub Server 시작 스크립트

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR/servers/s2opc"

echo "S2OPC PubSub 서버 시작 중..."

# S2OPC pubsub_server는 기본 포트를 사용
# TODO: 포트 4845 사용을 위해 설정 파일 또는 인자 전달 필요
cd build/bin
./pubsub_server > $ROOT_DIR/logs/s2opc_server.log 2>&1 &
S2OPC_PID=$!

cd $ROOT_DIR
echo "$S2OPC_PID" >> server_pids.txt

sleep 3

echo "S2OPC 서버 시작됨 (PID: $S2OPC_PID)"
echo "포트 확인 (기본 포트):"
ss -tuln | grep -E "484[0-9]" || netstat -tuln | grep -E "484[0-9]"

echo ""
echo "서버 로그:"
tail -30 logs/s2opc_server.log 2>/dev/null || echo "Log file not created yet"

