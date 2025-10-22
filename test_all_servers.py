#!/usr/bin/env python3
"""모든 OPC UA 서버 연결 테스트"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client

servers = [
    ("S2OPC", "opc.tcp://localhost:4840"),
    ("Python opcua", "opc.tcp://localhost:4841/freeopcua/server/"),
    ("open62541", "opc.tcp://localhost:4842/open62541/server/"),
]

print("╔═══════════════════════════════════════════════════╗")
print("║       OPC UA 서버 연결 테스트                     ║")
print("╚═══════════════════════════════════════════════════╝")
print()

for name, url in servers:
    try:
        print(f"🔍 {name} 서버 테스트 ({url})...")
        client = Client(url)
        client.connect()
        
        # 서버 정보 가져오기
        root = client.get_root_node()
        objects = client.get_objects_node()
        
        print(f"   ✅ 연결 성공!")
        print(f"   📋 Objects 노드: {objects}")
        
        # 자식 노드 출력
        children = objects.get_children()
        print(f"   📁 객체 개수: {len(children)}")
        
        client.disconnect()
        print()
        
    except Exception as e:
        print(f"   ❌ 연결 실패: {e}")
        print()

print("╚═══════════════════════════════════════════════════╝")
print("테스트 완료!")
