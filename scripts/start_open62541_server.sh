#!/bin/bash
# open62541 C 서버 시작 스크립트

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "open62541 C 서버 시작 중..."

# open62541 기본 포트는 4840이지만, 논문용으로 4841 사용
# tutorial_server_firststeps는 포트 인자를 받지 않으므로 기본 4840 사용
# TODO: 포트 4841 사용을 위해 직접 빌드된 바이너리 호출 필요
cd open62541/build/bin/examples
./tutorial_server_firststeps > $ROOT_DIR/logs/open62541_server.log 2>&1 &
OPEN62541_PID=$!

cd $ROOT_DIR
echo "$OPEN62541_PID" >> server_pids.txt

sleep 2

echo "open62541 서버 시작됨 (PID: $OPEN62541_PID)"
echo "포트 확인 (기본 4840):"
ss -tuln | grep 4840 || netstat -tuln | grep 4840

echo ""
echo "서버 로그:"
tail -20 logs/open62541_server.log
