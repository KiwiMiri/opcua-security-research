#!/usr/bin/env python3
"""ANSSI 시나리오 재현용 서버 - 두 정책 모두 활성화"""
from opcua import ua, Server
import time
import logging

logging.basicConfig(level=logging.ERROR)

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 핵심: 두 정책 모두 활성화 (암호화 + None)
    server.set_security_policy([
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,  # 정상
        ua.SecurityPolicyType.NoSecurity  # 다운그레이드용
    ])
    
    idx = server.register_namespace("urn:research:server")
    objects = server.get_objects_node()
    device = objects.add_object(idx, "ResearchDevice")
    device.add_variable(idx, "Temperature", 25.0)
    
    server.start()
    print("ANSSI 서버 시작: 암호화 + None 두 정책 활성화")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop()

if __name__ == "__main__":
    main()
