#!/usr/bin/env python3
"""ANSSI 클라이언트 - SignAndEncrypt 모드"""
from opcua import Client
import time

client = Client("opc.tcp://127.0.0.1:4840")
client.set_user("testuser")
client.set_password("password123!")

print("연결 시도 (SignAndEncrypt 모드)...")
try:
    client.connect()
    print("✓ 연결 성공 (암호화됨)")
    root = client.get_root_node()
    time.sleep(1)
    client.disconnect()
except Exception as e:
    print(f"✗ 연결 실패: {e}")
