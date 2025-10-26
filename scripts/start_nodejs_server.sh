#!/bin/bash
cd /root/opcua-research

echo "Node.js OPC UA 서버 시작 중..."
node servers/nodejs/opcua_server.js > logs/nodejs_server.log 2>&1 &
echo $! >> server_pids.txt
echo "Node.js 서버 PID: $!"
