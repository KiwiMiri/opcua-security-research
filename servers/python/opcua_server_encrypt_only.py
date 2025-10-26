#!/usr/bin/env python3
"""ANSSI 시나리오용 서버 - SignAndEncrypt만 (None 제거)"""
from opcua import ua, Server
import time
import logging

logging.basicConfig(level=logging.ERROR)

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 암호화만 활성화 (None 제거)
    server.set_security_policy([ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt])
    
    idx = server.register_namespace("urn:research:server")
    objects = server.get_objects_node()
    device = objects.add_object(idx, "ResearchDevice")
    device.add_variable(idx, "Temperature", 25.0)
    
    server.start()
    print("ANSSI 서버 시작: SignAndEncrypt만 활성화 (None 제거)")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop()

if __name__ == "__main__":
    main()
