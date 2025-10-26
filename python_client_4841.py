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
