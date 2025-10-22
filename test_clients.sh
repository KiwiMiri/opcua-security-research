#!/bin/bash
# OPC UA 클라이언트 테스트 스크립트

BASE_DIR="/root/opcua-research"

echo "════════════════════════════════════════════════════"
echo "OPC UA 클라이언트 테스트 스크립트"
echo "════════════════════════════════════════════════════"
echo ""

# 1. open62541 클라이언트로 테스트 (포트 4842)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/3] open62541 서버 테스트 (포트 4842)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "클라이언트 실행 명령:"
echo "${BASE_DIR}/open62541-1.3.8/build/bin/examples/tutorial_client_firststeps"
echo ""

# 2. Python opcua 클라이언트로 테스트 (포트 4841)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/3] Python opcua 서버 테스트 (포트 4841)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "${BASE_DIR}/python_client_4841.py" << 'PYEOF'
#!/usr/bin/env python3
"""
Python opcua 클라이언트 예제 (포트 4841 서버 연결)
"""
import sys
try:
    from opcua import Client
    
    client = Client("opc.tcp://localhost:4841/freeopcua/server/")
    
    try:
        print("포트 4841 서버에 연결 중...")
        client.connect()
        print("✅ 연결 성공!")
        
        # 루트 노드 가져오기
        root = client.get_root_node()
        print(f"Root node: {root}")
        print(f"Server name: {client.get_server_node().get_browse_name()}")
        
        # 객체 찾기
        objects = client.get_objects_node()
        print(f"Objects node: {objects}")
        
        # 자식 노드 나열
        print("\n사용 가능한 객체:")
        for child in objects.get_children():
            print(f"  - {child.get_browse_name()}")
        
    finally:
        client.disconnect()
        print("연결 종료")
        
except Exception as e:
    print(f"❌ 오류: {e}")
    sys.exit(1)
PYEOF

chmod +x "${BASE_DIR}/python_client_4841.py"
echo "클라이언트 실행 명령:"
echo "${BASE_DIR}/python-opcua-env/bin/python ${BASE_DIR}/python_client_4841.py"
echo ""

# 3. S2OPC 클라이언트로 테스트 (포트 4840)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/3] S2OPC 서버 테스트 (포트 4840)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "클라이언트 실행 명령 예시:"
echo "${BASE_DIR}/S2OPC-1.4.0/build/bin/s2opc_read --help"
echo ""

echo "════════════════════════════════════════════════════"
echo "빠른 테스트 실행"
echo "════════════════════════════════════════════════════"
echo ""

# Python 클라이언트 자동 실행
if ps aux | grep -q "[p]ython_server_4841"; then
    echo "Python opcua 서버(4841) 테스트 중..."
    ${BASE_DIR}/python-opcua-env/bin/python ${BASE_DIR}/python_client_4841.py
    echo ""
else
    echo "⚠️  Python opcua 서버가 실행되지 않았습니다 (포트 4841)"
    echo "   서버 시작: ./start_servers.sh"
    echo ""
fi

echo "════════════════════════════════════════════════════"
echo "포트 요약"
echo "════════════════════════════════════════════════════"
netstat -tuln 2>/dev/null | grep -E "4840|4841|4842" || echo "서버가 실행되지 않았습니다"
echo ""

