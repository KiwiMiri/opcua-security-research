#!/usr/bin/env python3
"""
open62541 v1.4.14 스타일 서버 (패치 버전)
포트: 5842
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:5842/open62541/server/")
    server.set_server_name("open62541 v1.4.14 Patched Server (Port 5842)")
    
    # 패치 버전: 보안 정책 강화
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    uri = "http://open62541.org/patched"
    idx = server.register_namespace(uri)
    
    objects = server.get_objects_node()
    test_folder = objects.add_folder(idx, "TestFolder_Patched")
    
    the_answer = test_folder.add_variable(idx, "the answer", 42)
    the_answer.set_writable()
    
    version_var = test_folder.add_variable(idx, "Version", "1.4.14-patched")
    version_var.set_writable()
    
    server_time = test_folder.add_variable(idx, "ServerTime", time.time())
    server_time.set_writable()
    
    server.start()
    print(f"open62541 v1.4.14 패치 서버가 포트 5842에서 시작되었습니다")
    print(f"URL: opc.tcp://localhost:5842/open62541/server/")
    print(f"Version: 1.4.14 (Patched)")
    
    try:
        while True:
            server_time.set_value(time.time())
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        server.stop()

if __name__ == "__main__":
    main()

