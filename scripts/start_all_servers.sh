#!/bin/bash
cd /root/opcua-research

echo "=== 모든 OPC UA 서버 시작 ==="
./scripts/start_python_server.sh
sleep 2
./scripts/start_nodejs_server.sh
sleep 2
./scripts/start_open62541_server.sh
sleep 2
./scripts/start_freeopcua_server.sh
sleep 2
./scripts/start_eclipse_milo_server.sh

echo "모든 서버가 시작되었습니다."
echo "PID 파일: server_pids.txt"
