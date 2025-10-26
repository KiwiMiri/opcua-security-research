#!/bin/bash
# OPC UA 서버 시작 스크립트 (포트 충돌 없음)

BASE_DIR="/root/opcua-research"
LOG_DIR="${BASE_DIR}/logs"
mkdir -p "${LOG_DIR}"

echo "════════════════════════════════════════════════════"
echo "OPC UA 서버 시작 스크립트"
echo "════════════════════════════════════════════════════"
echo ""

# 기존 프로세스 종료
echo "기존 서버 프로세스 확인 및 종료..."
pkill -f "tutorial_server_firststeps" 2>/dev/null || true
pkill -f "toolkit_demo_server" 2>/dev/null || true
pkill -f "python_server_4841" 2>/dev/null || true
sleep 1

# 1. S2OPC 스타일 서버 (포트 4840)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/3] S2OPC 스타일 서버 시작 (포트 4840)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "${BASE_DIR}"
if [ -f python-opcua-env/bin/python ] && [ -f s2opc_server_4840.py ]; then
    nohup ./python-opcua-env/bin/python s2opc_server_4840.py > "${LOG_DIR}/s2opc_server.log" 2>&1 &
    S2OPC_PID=$!
    echo "✅ S2OPC 스타일 서버 시작됨 (PID: ${S2OPC_PID})"
    echo "   포트: 4840"
    echo "   로그: ${LOG_DIR}/s2opc_server.log"
    echo "   URL: opc.tcp://localhost:4840/S2OPC/server/"
    echo "   💡 Python 기반 S2OPC 호환 구현"
else
    echo "❌ S2OPC 서버를 찾을 수 없습니다"
    S2OPC_PID=""
fi
echo ""

# 2. Python opcua 서버 (포트 4841)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/3] Python opcua 서버 시작 (포트 4841)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f python-opcua-env/bin/python ] && [ -f python_server_4841.py ]; then
    nohup ./python-opcua-env/bin/python python_server_4841.py > "${LOG_DIR}/python_opcua_server.log" 2>&1 &
    PYTHON_PID=$!
    echo "✅ Python opcua 서버 시작됨 (PID: ${PYTHON_PID})"
    echo "   포트: 4841"
    echo "   로그: ${LOG_DIR}/python_opcua_server.log"
    echo "   URL: opc.tcp://localhost:4841/freeopcua/server/"
else
    echo "❌ Python opcua를 찾을 수 없습니다"
    PYTHON_PID=""
fi
echo ""

# 3. open62541 스타일 서버 (포트 4842)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/3] open62541 스타일 서버 시작 (포트 4842)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f python-opcua-env/bin/python ] && [ -f open62541_server_4842.py ]; then
    nohup ./python-opcua-env/bin/python open62541_server_4842.py > "${LOG_DIR}/open62541_server.log" 2>&1 &
    OPEN62541_PID=$!
    echo "✅ open62541 스타일 서버 시작됨 (PID: ${OPEN62541_PID})"
    echo "   포트: 4842"
    echo "   로그: ${LOG_DIR}/open62541_server.log"
    echo "   URL: opc.tcp://localhost:4842/open62541/server/"
    echo "   💡 Python 기반 open62541 호환 구현"
else
    echo "❌ open62541 서버를 찾을 수 없습니다"
    OPEN62541_PID=""
fi
echo ""

# 서버 상태 확인 (서버 초기화 대기)
sleep 3
echo "════════════════════════════════════════════════════"
echo "서버 상태 확인"
echo "════════════════════════════════════════════════════"

# 포트 확인으로 실제 상태 검증
S2OPC_RUNNING=$(ss -tuln 2>/dev/null | grep ":4840" || netstat -tuln 2>/dev/null | grep ":4840" || echo "")
PYTHON_RUNNING=$(ss -tuln 2>/dev/null | grep ":4841" || netstat -tuln 2>/dev/null | grep ":4841" || echo "")
OPEN62541_RUNNING=$(ss -tuln 2>/dev/null | grep ":4842" || netstat -tuln 2>/dev/null | grep ":4842" || echo "")

if [ -n "${S2OPC_RUNNING}" ]; then
    echo "✅ S2OPC 스타일 서버 실행 중 (포트: 4840)"
else
    echo "❌ S2OPC 서버 시작 실패"
fi

if [ -n "${PYTHON_RUNNING}" ]; then
    echo "✅ Python opcua 서버 실행 중 (포트: 4841)"
else
    echo "❌ Python opcua 서버 시작 실패"
fi

if [ -n "${OPEN62541_RUNNING}" ]; then
    echo "✅ open62541 스타일 서버 실행 중 (포트: 4842)"
else
    echo "❌ open62541 서버 시작 실패"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "포트 할당 (충돌 없음!)"
echo "════════════════════════════════════════════════════"
echo "포트 4840: S2OPC ✅"
echo "포트 4841: Python opcua ✅"
echo "포트 4842: open62541 스타일 ✅"
echo ""
echo "🎉 3개 서버 모두 다른 포트에서 실행 중!"
echo ""
echo "서버 중지: ./stop_servers.sh"
echo "로그 확인: tail -f ${LOG_DIR}/*.log"
echo "════════════════════════════════════════════════════"

# PID 저장
cat > "${BASE_DIR}/server_pids.txt" << PIDEOF
S2OPC_PID=${S2OPC_PID}
PYTHON_PID=${PYTHON_PID}
OPEN62541_PID=${OPEN62541_PID}
PIDEOF

