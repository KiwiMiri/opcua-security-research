#!/usr/bin/env python3
"""
S2OPC 스타일 OPC UA 서버 (포트 4840)
Python opcua로 S2OPC와 유사한 보안 설정 구현
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840/S2OPC/server/")
    server.set_server_name("S2OPC-style Server (Port 4840)")
    
    # S2OPC 스타일: 보안 정책 설정 (인증서 모드 시뮬레이션)
    # 실제로는 NoSecurity지만 S2OPC 스타일의 구조
    server.set_security_policy([
        ua.SecurityPolicyType.NoSecurity,
    ])
    
    # 네임스페이스 추가
    uri = "urn:S2OPC:python-impl"
    idx = server.register_namespace(uri)
    
    # S2OPC 데모와 유사한 객체 구조
    objects = server.get_objects_node()
    
    # S2OPC Demo 객체
    demo_obj = objects.add_object(idx, "S2OPC_Demo")
    
    # 테스트 변수들
    counter = demo_obj.add_variable(idx, "Counter", 0)
    counter.set_writable()
    
    status = demo_obj.add_variable(idx, "ServerStatus", "Running")
    status.set_writable()
    
    timestamp = demo_obj.add_variable(idx, "Timestamp", time.time())
    timestamp.set_writable()
    
    # 서버 시작
    server.start()
    print(f"✅ S2OPC 스타일 서버가 포트 4840에서 시작되었습니다")
    print(f"   URL: opc.tcp://localhost:4840/S2OPC/server/")
    print(f"   S2OPC와 호환되는 Python 구현 (NoSecurity)")
    
    try:
        count = 0
        while True:
            time.sleep(1)
            count += 1
            counter.set_value(count)
            timestamp.set_value(time.time())
            
            if count % 10 == 0:
                print(f"[{time.strftime('%H:%M:%S')}] S2OPC 스타일 서버 실행 중... (Counter: {count})")
    except KeyboardInterrupt:
        print("\n서버 종료 중...")
    finally:
        server.stop()
        print("✅ 서버 종료됨")

if __name__ == "__main__":
    main()
