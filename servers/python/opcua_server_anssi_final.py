#!/usr/bin/env python3
"""ANSSI 시나리오 - SignAndEncrypt + None 두 정책"""
from opcua import ua, Server
import time
import logging
import os

logging.basicConfig(level=logging.ERROR)

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 두 정책 모두 활성화
    server.set_security_policy([
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
        ua.SecurityPolicyType.NoSecurity
    ])
    
    # 인증서 로드 (있는 경우)
    cert_dir = "/root/opcua-research/certs_new"
    try:
        server_cert = os.path.join(cert_dir, "server.cert.pem")
        server_key = os.path.join(cert_dir, "server.key.pem")
        if os.path.exists(server_cert) and os.path.exists(server_key):
            server.load_certificate(server_cert)
            server.load_private_key(server_key)
            print(f"✅ 인증서 로드: {server_cert}")
        else:
            print("⚠️ 인증서 없음, NoSecurity만 동작")
    except Exception as e:
        print(f"⚠️ 인증서 로드 실패: {e}")
    
    idx = server.register_namespace("urn:research:server")
    objects = server.get_objects_node()
    device = objects.add_object(idx, "ResearchDevice")
    device.add_variable(idx, "Temperature", 25.0)
    
    server.start()
    print("ANSSI 서버 시작: SignAndEncrypt + None")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop()

if __name__ == "__main__":
    main()
