#!/bin/bash
# OPC UA 클라이언트 생성 스크립트

BASE_DIR="/root/opcua-research"
CLIENTS_DIR="${BASE_DIR}/clients"

mkdir -p "${CLIENTS_DIR}/python" "${CLIENTS_DIR}/nodejs"

# Python OPC UA 클라이언트
cat > "${CLIENTS_DIR}/python/client.py" << 'PYTHON_EOF'
#!/usr/bin/env python3
import sys
sys.path.insert(0, '/root/opcua-research/venv/lib/python3.12/site-packages')

import logging
from opcua import Client

logging.basicConfig(level=logging.ERROR)

def test_client(endpoint, name):
    try:
        client = Client(endpoint)
        client.connect()
        
        # 간단한 읽기 테스트
        objects = client.get_objects_node()
        print(f"[{name}] 연결 성공: {endpoint}")
        
        # 서버 정보 읽기
        try:
            server_node = client.get_server_node()
            print(f"[{name}] 서버 이름: {server_node.get_display_name().Text}")
        except:
            pass
        
        client.disconnect()
        return True
    except Exception as e:
        print(f"[{name}] 연결 실패: {e}")
        return False

# 각 서버에 연결 시도
test_client("opc.tcp://localhost:4840/freeopcua/server/", "Python Server")
test_client("opc.tcp://localhost:4841/UA/ResearchServer", "Node.js Server")
test_client("opc.tcp://localhost:4842", "open62541 Server")
test_client("opc.tcp://localhost:4843/freeopcua/server/", "FreeOpcUa Server")
test_client("opc.tcp://localhost:4844/UA/ResearchServer", "Eclipse Milo Server")
PYTHON_EOF

chmod +x "${CLIENTS_DIR}/python/client.py"

# Node.js OPC UA 클라이언트
cat > "${CLIENTS_DIR}/nodejs/client.js" << 'JS_EOF'
const { OPCUAClient } = require("node-opcua");

async function testClient(endpoint, name) {
    const client = OPCUAClient.create({});
    
    try {
        await client.connect(endpoint);
        console.log(`[${name}] 연결 성공: ${endpoint}`);
        
        const session = await client.createSession();
        console.log(`[${name}] 세션 생성 성공`);
        
        await session.close();
        await client.disconnect();
        return true;
    } catch (err) {
        console.log(`[${name}] 연결 실패:`, err.message);
        return false;
    }
}

async function main() {
    await testClient("opc.tcp://localhost:4840/freeopcua/server/", "Python Server");
    await testClient("opc.tcp://localhost:4841/UA/ResearchServer", "Node.js Server");
    await testClient("opc.tcp://localhost:4842", "open62541 Server");
    await testClient("opc.tcp://localhost:4843/freeopcua/server/", "FreeOpcUa Server");
    await testClient("opc.tcp://localhost:4844/UA/ResearchServer", "Eclipse Milo Server");
    
    process.exit(0);
}

main();
JS_EOF

chmod +x "${CLIENTS_DIR}/nodejs/client.js"

echo "클라이언트 생성 완료"
echo "  - Python: ${CLIENTS_DIR}/python/client.py"
echo "  - Node.js: ${CLIENTS_DIR}/nodejs/client.js"
