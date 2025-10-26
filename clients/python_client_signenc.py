#!/usr/bin/env python3
from opcua import Client
import time

print("클라이언트 연결 시도...")
client = Client("opc.tcp://127.0.0.1:4840")
client.set_user("testuser")
client.set_password("password123!")

try:
    client.connect()
    print("✅ 연결 성공")
    root = client.get_root_node()
    print(f"✓ 루트: {root}")
    time.sleep(1)
    client.disconnect()
except Exception as e:
    print(f"❌ 연결 실패: {e}")
    import traceback
    traceback.print_exc()
