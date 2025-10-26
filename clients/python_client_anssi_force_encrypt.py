#!/usr/bin/env python3
"""ANSSI 클라이언트 - SignAndEncrypt 강제"""
from opcua import Client
import time

# SignAndEncrypt 강제 (우선순위 높이기)
client = Client("opc.tcp://127.0.0.1:4840")
client.set_user("testuser")
client.set_password("password123!")

# 보안 모드 강제 설정
client.set_security_string("SignAndEncrypt")

print("연결 시도 (SignAndEncrypt 강제)...")
try:
    client.connect()
    print("✓ 연결 성공")
    root = client.get_root_node()
    time.sleep(1)
    client.disconnect()
except Exception as e:
    print(f"✗ 연결 실패: {e}")
