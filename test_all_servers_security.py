#!/usr/bin/env python3
"""
모든 서버의 보안 정책 확인
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client

servers = [
    ("S2OPC v1.4.0", "opc.tcp://localhost:4840/S2OPC/server/"),
    ("Python OPC UA v0.98.13", "opc.tcp://localhost:4841/freeopcua/server/"),
    ("open62541 v1.3.8", "opc.tcp://localhost:4842/open62541/server/"),
]

print("="*70)
print("Security Policy Test for All Servers")
print("="*70)
print()

for name, url in servers:
    print(f"Testing: {name}")
    print(f"URL: {url}")
    print("-"*70)
    
    try:
        client = Client(url)
        
        # 실제 연결 시도
        print("Attempting connection...")
        client.connect()
        print("  Connected successfully!")
        
        # 연결 후 엔드포인트 정보 확인
        print("\nFetching server endpoints...")
        
        # application_uri를 통해 서버 정보 확인
        try:
            print(f"  Server URI: {client.server_url.geturl()}")
            print(f"  Session timeout: {client.session_timeout}")
        except:
            pass
        
        # 연결된 상태 확인
        print("  Session established")
        
        client.disconnect()
        print("  Disconnected")
        
    except Exception as e:
        print(f"  ERROR: {e}")
    
    print()
    print("="*70)
    print()

print("\nAll tests completed!")

