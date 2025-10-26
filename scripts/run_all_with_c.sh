#!/bin/bash
# 모든 구현체 테스트 (C 구현체 포함)

set -e

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "모든 OPC UA 구현체 테스트 (C 포함)"
echo "=========================================="

# 기존 프로세스 정리
echo "기존 프로세스 종료 중..."
pkill -f "opcua_server" || true
pkill -f "node.*opcua" || true
pkill -f "ci_server" || true
pkill -f "tutorial_server" || true
sleep 2

mkdir -p logs pcaps

# Python-opcua 서버 시작
echo "[1/5] Python-opcua 서버 시작..."
source venv/bin/activate
python3 servers/python/opcua_server.py > logs/pythonopcua_server.log 2>&1 &
PYTHON_PID=$!
echo "$PYTHON_PID" > server_pids.txt
sleep 2

# FreeOpcUa 서버 시작
echo "[2/5] FreeOpcUa 서버 시작..."
python3 servers/freeopcua/opcua_server.py > logs/freeopcua_server.log 2>&1 &
FREE_PID=$!
echo "$FREE_PID" >> server_pids.txt
sleep 2

# Node.js-opcua 서버 시작
echo "[3/5] Node.js-opcua 서버 시작..."
cd servers/nodejs
node opcua_server.js > ../../logs/nodeopcua_server.log 2>&1 &
NODE_PID=$!
echo "$NODE_PID" >> $ROOT_DIR/server_pids.txt
sleep 2

# C 구현체 서버 시작
echo "[4/5] open62541 C 서버 시작..."
cd $ROOT_DIR/open62541/build/bin/examples
./ci_server > $ROOT_DIR/logs/open62541_server.log 2>&1 &
OPEN62541_PID=$!
echo "$OPEN62541_PID" >> $ROOT_DIR/server_pids.txt
sleep 3

cd $ROOT_DIR

# 포트 확인
echo ""
echo "서버 상태:"
ss -tuln | grep -E '484[0-9]' || netstat -tuln | grep -E '484[0-9]'

# PCAP 캡처
DATE_SUFFIX=$(date +%Y%m%d_%H%M%S)
echo ""
echo "PCAP 캡처 시작..."

sudo tcpdump -i any -s 0 -w pcaps/pythonopcua_${DATE_SUFFIX}.pcap 'tcp port 4840' &
CAPTURE_PYTHON=$!

sudo tcpdump -i any -s 0 -w pcaps/freeopcua_${DATE_SUFFIX}.pcap 'tcp port 4842' &
CAPTURE_FREE=$!

sudo tcpdump -i any -s 0 -w pcaps/nodeopcua_${DATE_SUFFIX}.pcap 'tcp port 4841' &
CAPTURE_NODE=$!

sleep 2

# 클라이언트 테스트
echo ""
echo "클라이언트 연결 테스트..."

# Python-opcua
echo "  Python-opcua..."
source venv/bin/activate
timeout 5 python3 clients/python_client_username.py > logs/pythonopcua_client.log 2>&1 || true
sleep 1

# FreeOpcUa
echo "  FreeOpcUa..."
timeout 5 python3 clients/freeopcua_client.py > logs/freeopcua_client.log 2>&1 || true
sleep 1

# Node.js-opcua
echo "  Node.js-opcua..."
timeout 10 node clients/nodejs_client.js > logs/nodeopcua_client.log 2>&1 || true
sleep 1

# 캡처 종료
sudo kill $CAPTURE_PYTHON $CAPTURE_FREE $CAPTURE_NODE 2>/dev/null || true
sleep 1

echo ""
echo "=========================================="
echo "결과 확인"
echo "=========================================="
ls -lh pcaps/*_${DATE_SUFFIX}.pcap

echo ""
echo "클라이언트 로그:"
for log in logs/*_client.log; do
    echo "--- $(basename $log) ---"
    cat "$log" | head -10
    echo ""
done

echo ""
echo "서버 PID: $PYTHON_PID $FREE_PID $NODE_PID $OPEN62541_PID"
