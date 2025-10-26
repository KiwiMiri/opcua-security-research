#!/usr/bin/env python3
"""
Python opcua v0.98.13 서버 (동일 버전)
포트: 5841
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:5841/freeopcua/server/")
    server.set_server_name("Python OPC UA Server v0.98.13 (Port 5841)")
    
    # 동일 버전이지만 포트만 변경
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    uri = "http://examples.freeopcua.github.io"
    idx = server.register_namespace(uri)
    
    objects = server.get_objects_node()
    myobj = objects.add_object(idx, "PythonTestObject")
    
    myvar = myobj.add_variable(idx, "PythonTestVariable", 42)
    myvar.set_writable()
    
    version_var = myobj.add_variable(idx, "Version", "0.98.13")
    version_var.set_writable()
    
    server.start()
    print(f"Python opcua v0.98.13 서버가 포트 5841에서 시작되었습니다")
    print(f"URL: opc.tcp://localhost:5841/freeopcua/server/")
    print(f"Version: 0.98.13 (Same as vulnerable)")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        server.stop()

if __name__ == "__main__":
    main()

