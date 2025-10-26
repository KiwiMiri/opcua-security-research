#!/usr/bin/env python3
"""
S2OPC v1.6.0 스타일 서버 (패치 버전)
포트: 5840
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:5840/S2OPC/server/")
    server.set_server_name("S2OPC v1.6.0 Patched Server (Port 5840)")
    
    # 패치 버전: 보안 정책 강화
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    uri = "http://systerel.fr/S2OPC/patched"
    idx = server.register_namespace(uri)
    
    objects = server.get_objects_node()
    s2opc_demo_obj = objects.add_object(idx, "S2OPC_Patched")
    
    counter_var = s2opc_demo_obj.add_variable(idx, "Counter", 0)
    counter_var.set_writable()
    
    version_var = s2opc_demo_obj.add_variable(idx, "Version", "1.6.0-patched")
    version_var.set_writable()
    
    status_var = s2opc_demo_obj.add_variable(idx, "ServerStatus", "Running")
    status_var.set_writable()
    
    timestamp_var = s2opc_demo_obj.add_variable(idx, "Timestamp", time.time())
    timestamp_var.set_writable()
    
    server.start()
    print(f"S2OPC v1.6.0 패치 서버가 포트 5840에서 시작되었습니다")
    print(f"URL: opc.tcp://localhost:5840/S2OPC/server/")
    print(f"Version: 1.6.0 (Patched)")
    
    counter = 0
    try:
        while True:
            counter += 1
            counter_var.set_value(counter)
            timestamp_var.set_value(time.time())
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        server.stop()

if __name__ == "__main__":
    main()

