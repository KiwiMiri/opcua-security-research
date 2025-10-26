#!/bin/bash
cd /root/opcua-research
source venv/bin/activate

echo "FreeOpcUa OPC UA 서버 시작 중..."
python3 servers/freeopcua/opcua_server.py > logs/freeopcua_server.log 2>&1 &
echo $! >> server_pids.txt
echo "FreeOpcUa 서버 PID: $!"



