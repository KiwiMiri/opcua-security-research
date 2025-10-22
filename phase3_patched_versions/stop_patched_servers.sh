#!/bin/bash

###############################################################################
# Phase 3: 패치 버전 OPC UA 서버 종료 스크립트
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_FILE="$SCRIPT_DIR/patched_server_pids.txt"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛑 패치 버전 OPC UA 서버 종료 중...${NC}"
echo ""

# PID 파일에서 종료
if [ -f "$PID_FILE" ]; then
    echo "📋 PID 파일에서 프로세스 종료 중..."
    while read pid; do
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid 2>/dev/null
            echo -e "   ${GREEN}✅ PID $pid 종료${NC}"
        else
            echo -e "   ${YELLOW}⚠️  PID $pid 이미 종료됨${NC}"
        fi
    done < "$PID_FILE"
    rm -f "$PID_FILE"
fi

# 프로세스 이름으로도 종료
echo ""
echo "🔍 프로세스 이름으로 종료 중..."
pkill -f "s2opc_server_5840.py" && echo -e "   ${GREEN}✅ s2opc_server_5840.py 종료${NC}"
pkill -f "asyncua_server_5843.py" && echo -e "   ${GREEN}✅ asyncua_server_5843.py 종료${NC}"
pkill -f "open62541_server_5842.py" && echo -e "   ${GREEN}✅ open62541_server_5842.py 종료${NC}"

sleep 2

# 포트 확인
echo ""
echo "🔍 포트 확인 중..."
for port in 5840 5843 5842; do
    if lsof -i :$port >/dev/null 2>&1; then
        echo -e "   ${RED}❌ 포트 $port 여전히 사용 중${NC}"
        lsof -i :$port
    else
        echo -e "   ${GREEN}✅ 포트 $port 해제됨${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ 패치 버전 서버 종료 완료!${NC}"
echo ""

