#!/bin/bash
cd /root/opcua-research
source venv/bin/activate

echo "Python OPC UA 서버 시작 중..."
python3 servers/python/opcua_server.py > logs/python_server.log 2>&1 &
echo $! > server_pids.txt
echo "Python 서버 PID: $!"
