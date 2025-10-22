#!/usr/bin/env python3
"""
MITM 프록시 테스트 클라이언트
프록시(14841)를 통해 서버(4841)에 연결하여 패킷 조작 확인
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import time

def test_through_proxy():
    """프록시를 통한 연결 테스트"""
    print("="*70)
    print("MITM Proxy Test Client")
    print("="*70)
    print()
    
    # 프록시를 통해 연결 (localhost:14841 -> localhost:4841)
    proxy_url = "opc.tcp://localhost:14841/freeopcua/server/"
    
    print(f"Connecting through proxy: {proxy_url}")
    print()
    
    try:
        client = Client(proxy_url)
        print("[1] Creating client...")
        
        print("[2] Connecting to server via proxy...")
        client.connect()
        print("    Connected successfully!")
        print()
        
        print("[3] Getting server info...")
        print(f"    Server Name: {client.get_server_node().get_browse_name()}")
        print()
        
        print("[4] Browsing objects...")
        objects = client.get_objects_node()
        children = objects.get_children()
        print(f"    Found {len(children)} objects")
        
        for i, child in enumerate(children[:3], 1):
            name = child.get_browse_name()
            print(f"    [{i}] {name}")
        print()
        
        print("[5] Reading a variable...")
        try:
            var = client.get_node("ns=2;i=2")
            value = var.get_value()
            print(f"    Value: {value}")
        except Exception as e:
            print(f"    Could not read variable: {e}")
        print()
        
        print("[6] Disconnecting...")
        client.disconnect()
        print("    Disconnected")
        print()
        
        print("="*70)
        print("Test completed successfully!")
        print("="*70)
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_through_proxy()

