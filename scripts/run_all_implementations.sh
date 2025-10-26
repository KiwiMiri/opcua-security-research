#!/bin/bash
# 모든 OPC UA 구현체 병렬 테스트 스크립트

set -e

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "모든 OPC UA 구현체 병렬 테스트 시작"
echo "=========================================="

# 로그 디렉토리 생성
mkdir -p logs
mkdir -p pcaps
mkdir -p reports

# 기존 프로세스 정리
echo "기존 OPC UA 서버 프로세스 종료 중..."
pkill -f "opcua_server" || true
pkill -f "node.*opcua" || true
sleep 2

# Python-opcua 서버 시작
echo "[1/4] Python-opcua 서버 시작..."
cd $ROOT_DIR
source venv/bin/activate
python3 servers/python/opcua_server.py > logs/pythonopcua_server.log 2>&1 &
PYTHONOPCUA_PID=$!
echo "$PYTHONOPCUA_PID" > server_pids.txt
sleep 3
echo "  ✓ PID: $PYTHONOPCUA_PID"

# Node.js-opcua 서버 시작
echo "[2/4] Node.js-opcua 서버 시작..."
cd servers/nodejs
if [ ! -d "node_modules" ]; then
    echo "  npm 패키지 설치 중..."
    npm init -y
    npm install node-opcua
fi
node opcua_server.js > ../../logs/nodeopcua_server.log 2>&1 &
NODEOPCUA_PID=$!
echo "$NODEOPCUA_PID" >> $ROOT_DIR/server_pids.txt
sleep 3
echo "  ✓ PID: $NODEOPCUA_PID"

# FreeOpcUa 서버 시작
echo "[3/4] FreeOpcUa 서버 시작..."
cd $ROOT_DIR
source venv/bin/activate
python3 servers/freeopcua/opcua_server.py > logs/freeopcua_server.log 2>&1 &
FREEOPCUA_PID=$!
echo "$FREEOPCUA_PID" >> server_pids.txt
sleep 3
echo "  ✓ PID: $FREEOPCUA_PID"

# 포트 확인
echo ""
echo "=========================================="
echo "서버 상태 확인"
echo "=========================================="
netstat -tuln 2>/dev/null | grep -E '484[0-4]' || ss -tunlp | grep -E '484[0-4]'

echo ""
echo "=========================================="
echo "병렬 캡처 및 클라이언트 테스트 시작"
echo "=========================================="

# PCAP 캡처 시작
DATE_SUFFIX=$(date +%Y%m%d_%H%M%S)
sudo tcpdump -i any -s 0 -w pcaps/pythonopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4840' &
CAPTURE_PYTHON=$!

sudo tcpdump -i any -s 0 -w pcaps/nodeopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4841' &
CAPTURE_NODE=$!

sudo tcpdump -i any -s 0 -w pcaps/freeopcua_test_${DATE_SUFFIX}.pcap 'tcp port 4842' &
CAPTURE_FREE=$!

sleep 2

echo "[4/4] 클라이언트 연결 시도..."
# Python-opcua 클라이언트
echo "  Python-opcua 클라이언트..."
source venv/bin/activate
timeout 5 python3 clients/python_client_username.py > logs/pythonopcua_client.log 2>&1 || true
sleep 2

# Node.js-opcua 클라이언트
echo "  Node.js-opcua 클라이언트..."
cd $ROOT_DIR
timeout 5 node clients/nodejs_client.js > logs/nodeopcua_client.log 2>&1 || true
sleep 2

# FreeOpcUa 클라이언트
echo "  FreeOpcUa 클라이언트..."
source venv/bin/activate
timeout 5 python3 clients/freeopcua_client.py > logs/freeopcua_client.log 2>&1 || true
sleep 2

echo "캡처 종료..."
sudo kill $CAPTURE_PYTHON $CAPTURE_NODE $CAPTURE_FREE 2>/dev/null || true
sleep 1

echo ""
echo "=========================================="
echo "결과 확인"
echo "=========================================="

ls -lh pcaps/*_test_${DATE_SUFFIX}.pcap 2>/dev/null || echo "PCAP 파일 없음"

echo ""
echo "=========================================="
echo "테스트 완료"
echo "=========================================="
echo "로그 디렉토리: logs/"
echo "PCAP 디렉토리: pcaps/"
echo ""
echo "서버 프로세스 종료하려면:"
echo "  kill $PYTHONOPCUA_PID $NODEOPCUA_PID $FREEOPCUA_PID"
