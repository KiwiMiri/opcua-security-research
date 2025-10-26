#!/usr/bin/env python3
"""ANSSI 시나리오 - 인증서 설정된 서버"""
from opcua import ua, Server
import time
import logging
import os

logging.basicConfig(level=logging.ERROR)

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # SignAndEncrypt + None 두 정책
    server.set_security_policy([
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
        ua.SecurityPolicyType.NoSecurity
    ])
    
    # 기존 인증서 사용
    try:
        server.load_certificate("certs/server-cert.pem")
        server.load_private_key("certs/server-key.pem")
        print("✅ 인증서 로드됨")
    except Exception as e:
        print(f"⚠️ 인증서 로드 실패: {e}")
    
    idx = server.register_namespace("urn:research:server")
    objects = server.get_objects_node()
    device = objects.add_object(idx, "ResearchDevice")
    device.add_variable(idx, "Temperature", 25.0)
    
    server.start()
    print("서버 시작: opc.tcp://0.0.0.0:4840")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop()

if __name__ == "__main__":
    main()
