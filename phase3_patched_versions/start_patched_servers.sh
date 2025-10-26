#!/bin/bash

###############################################################################
# Phase 3: 패치 버전 OPC UA 서버 시작 스크립트
# 포트: 5840 (S2OPC), 5841 (Python), 5842 (open62541)
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_FILE="$SCRIPT_DIR/patched_server_pids.txt"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     패치 버전 OPC UA 서버 시작 (포트 5840-5842)              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# PID 파일 초기화
> "$PID_FILE"

# Python venv 활성화
if [ -f "/root/opcua-research/python-opcua-env/bin/activate" ]; then
    source /root/opcua-research/python-opcua-env/bin/activate
    echo -e "${GREEN}✅ Python venv 활성화${NC}"
else
    echo -e "${RED}❌ Python venv를 찾을 수 없습니다${NC}"
    exit 1
fi

# 실행 권한 부여
chmod +x "$SCRIPT_DIR"/*.py

# 기존 서버 종료
echo -e "${YELLOW}🔍 기존 패치 버전 서버 확인 중...${NC}"
pkill -f "s2opc_server_5840.py" 2>/dev/null
pkill -f "python_server_5841.py" 2>/dev/null
pkill -f "open62541_server_5842.py" 2>/dev/null
sleep 1

# 포트 확인
for port in 5840 5841 5842 5843; do
    if lsof -i :$port >/dev/null 2>&1; then
        echo -e "${RED}❌ 포트 $port 이미 사용 중!${NC}"
        lsof -i :$port
        exit 1
    fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  서버 시작 중...${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 1. S2OPC v1.6.0 (포트 5840)
echo -e "${YELLOW}1️⃣  S2OPC v1.6.0 서버 시작 (포트 5840)...${NC}"
nohup python3 "$SCRIPT_DIR/s2opc_server_5840.py" > "$SCRIPT_DIR/s2opc_5840.log" 2>&1 &
S2OPC_PID=$!
echo "$S2OPC_PID" >> "$PID_FILE"
echo -e "   PID: $S2OPC_PID"
sleep 2

# 2. opcua-asyncio v1.1.8 (포트 5843) - Python OPC UA 최신
echo -e "${YELLOW}2️⃣  opcua-asyncio v1.1.8 서버 시작 (포트 5843)...${NC}"
nohup python3 "$SCRIPT_DIR/asyncua_server_5843.py" > "$SCRIPT_DIR/asyncua_5843.log" 2>&1 &
ASYNCUA_PID=$!
echo "$ASYNCUA_PID" >> "$PID_FILE"
echo -e "   PID: $ASYNCUA_PID"
echo -e "   ${GREEN}💡 python-opcua v0.98.13의 진화된 후속 버전${NC}"
sleep 2

# 3. open62541 v1.4.14 (포트 5842)
echo -e "${YELLOW}3️⃣  open62541 v1.4.14 서버 시작 (포트 5842)...${NC}"
nohup python3 "$SCRIPT_DIR/open62541_server_5842.py" > "$SCRIPT_DIR/open62541_5842.log" 2>&1 &
OPEN62541_PID=$!
echo "$OPEN62541_PID" >> "$PID_FILE"
echo -e "   PID: $OPEN62541_PID"
sleep 3

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  서버 상태 확인${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 포트 확인
if command -v ss >/dev/null 2>&1; then
    echo "📊 열린 포트:"
    ss -tuln | grep -E ":(5840|5841|5842)" || echo "   ⚠️  포트가 아직 바인딩되지 않았습니다"
elif command -v netstat >/dev/null 2>&1; then
    echo "📊 열린 포트:"
    netstat -tuln | grep -E ":(5840|5841|5842)" || echo "   ⚠️  포트가 아직 바인딩되지 않았습니다"
fi

echo ""

# 프로세스 확인
echo "📊 실행 중인 서버:"
for pid in $S2OPC_PID $ASYNCUA_PID $OPEN62541_PID; do
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "   ${GREEN}✅ PID $pid - 실행 중${NC}"
    else
        echo -e "   ${RED}❌ PID $pid - 종료됨${NC}"
    fi
done

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  연결 정보${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🔗 S2OPC v1.6.0:        opc.tcp://localhost:5840/S2OPC/server/"
echo "🔗 opcua-asyncio v1.1.8: opc.tcp://localhost:5843/asyncua/server/"
echo "🔗 open62541 v1.4.14:   opc.tcp://localhost:5842/open62541/server/"
echo ""
echo -e "${GREEN}✅ 패치 버전 서버 시작 완료!${NC}"
echo ""
echo "📝 PID 파일: $PID_FILE"
echo "📋 로그 파일:"
echo "   - $SCRIPT_DIR/s2opc_5840.log"
echo "   - $SCRIPT_DIR/asyncua_5843.log"
echo "   - $SCRIPT_DIR/open62541_5842.log"
echo ""
echo "🛑 서버 종료: ./stop_patched_servers.sh"
echo ""

