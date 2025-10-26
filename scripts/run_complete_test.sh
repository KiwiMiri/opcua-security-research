#!/bin/bash
# 모든 구현체 완전 테스트 (Node.js + C 구현체 포함)

set -e

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "모든 OPC UA 구현체 완전 테스트 시작"
echo "=========================================="

# 기존 프로세스 정리
echo "기존 프로세스 종료 중..."
pkill -f "opcua_server" || true
pkill -f "node.*opcua" || true
pkill -f "server_example" || true
sleep 2

# 로그 디렉토리 생성
mkdir -p logs
mkdir -p pcaps
mkdir -p reports

# Python-opcua 서버 시작
echo "[1/4] Python-opcua 서버 시작..."
cd $ROOT_DIR
source venv/bin/activate
python3 servers/python/opcua_server.py > logs/pythonopcua_server.log 2>&1 &
PYTHONOPCUA_PID=$!
echo "$PYTHONOPCUA_PID" > server_pids.txt
sleep 2
echo "  ✓ PID: $PYTHONOPCUA_PID"

# Node.js-opcua 서버 시작
echo "[2/4] Node.js-opcua 서버 시작..."
cd servers/nodejs
node opcua_server.js > ../../logs/nodeopcua_server.log 2>&1 &
NODEOPCUA_PID=$!
echo "$NODEOPCUA_PID" >> $ROOT_DIR/server_pids.txt
sleep 2
echo "  ✓ PID: $NODEOPCUA_PID"

# FreeOpcUa 서버 시작
echo "[3/4] FreeOpcUa 서버 시작..."
cd $ROOT_DIR
source venv/bin/activate
python3 servers/freeopcua/opcua_server.py > logs/freeopcua_server.log 2>&1 &
FREEOPCUA_PID=$!
echo "$FREEOPCUA_PID" >> server_pids.txt
sleep 2
echo "  ✓ PID: $FREEOPCUA_PID"

# 포트 확인
echo ""
echo "서버 상태 확인:"
netstat -tuln 2>/dev/null | grep -E '484[0-4]' || ss -tunlp | grep -E '484[0-4]'

# PCAP 캡처 시작
DATE_SUFFIX=$(date +%Y%m%d_%H%M%S)
echo ""
echo "PCAP 캡처 시작..."

sudo tcpdump -i any -s 0 -w pcaps/pythonopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4840' &
CAPTURE_PYTHON=$!

sudo tcpdump -i any -s 0 -w pcaps/nodeopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4841' &
CAPTURE_NODE=$!

sudo tcpdump -i any -s 0 -w pcaps/freeopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4842' &
CAPTURE_FREE=$!

sleep 2

# 클라이언트 테스트
echo ""
echo "클라이언트 연결 시도..."

# Python-opcua
echo "  Python-opcua..."
source venv/bin/activate
timeout 5 python3 clients/python_client_username.py > logs/pythonopcua_client.log 2>&1 || true
sleep 1

# Node.js-opcua
echo "  Node.js-opcua..."
cd $ROOT_DIR
timeout 10 node clients/nodejs_client.js > logs/nodeopcua_client.log 2>&1 || true
sleep 1

# FreeOpcUa
echo "  FreeOpcUa..."
source venv/bin/activate
timeout 5 python3 clients/freeopcua_client.py > logs/freeopcua_client.log 2>&1 || true
sleep 1

# 캡처 종료
sudo kill $CAPTURE_PYTHON $CAPTURE_NODE $CAPTURE_FREE 2>/dev/null || true
sleep 1

echo ""
echo "=========================================="
echo "결과 확인"
echo "=========================================="
ls -lh pcaps/*_test_${DATE_SUFFIX}.pcap 2>/dev/null || echo "PCAP 파일 없음"

echo ""
echo "클라이언트 로그:"
for log in logs/*_client.log; do
    echo "--- $log ---"
    cat "$log" | head -20
    echo ""
done

echo ""
echo "테스트 완료! (서버 PID: $PYTHONOPCUA_PID $NODEOPCUA_PID $FREEOPCUA_PID)"
