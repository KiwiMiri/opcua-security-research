#!/bin/bash
# OPC UA 서버 종료 스크립트

BASE_DIR="/root/opcua-research"

echo "════════════════════════════════════════════════════"
echo "OPC UA 서버 종료 스크립트"
echo "════════════════════════════════════════════════════"
echo ""

# PID 파일에서 읽기
if [ -f "${BASE_DIR}/server_pids.txt" ]; then
    source "${BASE_DIR}/server_pids.txt"
    
    if [ -n "${S2OPC_PID}" ] && ps -p ${S2OPC_PID} > /dev/null 2>&1; then
        echo "🛑 S2OPC 서버 종료 중 (PID: ${S2OPC_PID})..."
        kill ${S2OPC_PID}
    fi
    
    if [ -n "${PYTHON_PID}" ] && ps -p ${PYTHON_PID} > /dev/null 2>&1; then
        echo "🛑 Python opcua 서버 종료 중 (PID: ${PYTHON_PID})..."
        kill ${PYTHON_PID}
    fi
    
    if [ -n "${OPEN62541_PID}" ] && ps -p ${OPEN62541_PID} > /dev/null 2>&1; then
        echo "🛑 open62541 서버 종료 중 (PID: ${OPEN62541_PID})..."
        kill ${OPEN62541_PID}
    fi
    
    rm -f "${BASE_DIR}/server_pids.txt"
fi

# 프로세스명으로도 종료 시도
echo "🧹 남아있는 서버 프로세스 정리 중..."
pkill -f "toolkit_demo_server" 2>/dev/null || true
pkill -f "python_server_4841" 2>/dev/null || true
pkill -f "open62541_server_4842" 2>/dev/null || true

sleep 1

echo ""
echo "✅ 모든 서버가 종료되었습니다"
echo "════════════════════════════════════════════════════"

