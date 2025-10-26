#!/usr/bin/env python3
"""Python OPC UA 서버 - 간단 버전 (NoSecurity -> 테스트용)"""
from opcua import Server
import time
import logging

logging.basicConfig(level=logging.ERROR)

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 인증서 없이 NoSecurity (실험용)
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
