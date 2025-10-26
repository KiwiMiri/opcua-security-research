#!/usr/bin/env python3
"""Python OPC UA 클라이언트 - UserName/Password 인증"""
from opcua import Client
import time

def main():
    url = "opc.tcp://127.0.0.1:4840"
    username = "testuser"
    password = "password123!"
    
    print(f"서버 연결 중: {url}")
    print(f"사용자: {username}")
    
    client = Client(url)
    client.set_user(username)
    client.set_password(password)
    
    try:
        client.connect()
        print("✓ 연결 성공")
        
        # 간단한 읽기
        root = client.get_root_node()
        print(f"✓ 루트 노드: {root}")
        
        time.sleep(1)
        
    except Exception as e:
        print(f"✗ 연결 실패: {e}")
    finally:
        client.disconnect()
        print("연결 종료")

if __name__ == "__main__":
    main()
