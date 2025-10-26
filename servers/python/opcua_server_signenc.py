#!/usr/bin/env python3
from opcua import ua, Server
import time

print("서버 시작...")
server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840")

# SignAndEncrypt만 활성화
server.set_security_policy([ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt])
print("✅ 보안 정책: Basic256Sha256_SignAndEncrypt")

# 인증서 로드
try:
    server.load_certificate("certs/server-cert.pem")
    server.load_private_key("certs/server-key.pem")
    print("✅ 인증서 로드됨")
except Exception as e:
    print(f"❌ 인증서 로드 실패: {e}")

# 기본 설정
idx = server.register_namespace("urn:test")
objects = server.get_objects_node()
obj = objects.add_object(idx, "TestObject")
obj.add_variable(idx, "Temperature", 25.0)

server.start()
print("✅ 서버 시작: opc.tcp://0.0.0.0:4840")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    server.stop()
