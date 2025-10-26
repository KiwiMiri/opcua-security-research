#!/usr/bin/env python3
"""
실제 open62541 C 서버에 직접 연결
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client

print("="*70)
print("Direct Connection to Real open62541 v1.3.8 C Server")
print("="*70)
print()

try:
    # 포트 4850의 실제 open62541 서버에 직접 연결
    client = Client("opc.tcp://localhost:4850")
    print("Connecting to opc.tcp://localhost:4850...")
    
    client.connect()
    print("Connected successfully!")
    print()
    
    # 서버 정보
    server_node = client.get_server_node()
    print(f"Server Name: {server_node.get_browse_name()}")
    print()
    
    # 객체 탐색
    print("Browsing objects...")
    objects = client.get_objects_node()
    children = objects.get_children()
    print(f"Found {len(children)} objects:")
    for child in children[:5]:
        print(f"  - {child.get_browse_name()}")
    print()
    
    client.disconnect()
    print("Disconnected")
    print()
    
    print("="*70)
    print("SUCCESS: Real C implementation works!")
    print("="*70)
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

