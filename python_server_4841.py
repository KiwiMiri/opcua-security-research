#!/usr/bin/env python3
"""
Python opcua 서버 예제 (포트 4841)
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4841/freeopcua/server/")
    server.set_server_name("Python OPC UA Server (Port 4841)")
    
    # 보안 정책 설정 (취약 버전이므로 None으로 설정)
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    # 네임스페이스 추가
    uri = "http://examples.freeopcua.github.io"
    idx = server.register_namespace(uri)
    
    # 객체 추가
    objects = server.get_objects_node()
    myobj = objects.add_object(idx, "PythonTestObject")
    myvar = myobj.add_variable(idx, "PythonTestVariable", 42)
    myvar.set_writable()
    
    # 서버 시작
    server.start()
    print(f"Python opcua 서버가 포트 4841에서 시작되었습니다")
    print(f"URL: opc.tcp://localhost:4841/freeopcua/server/")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        server.stop()
        print("서버 종료됨")

if __name__ == "__main__":
    main()
