#!/usr/bin/env python3
"""
open62541 스타일 OPC UA 서버 (포트 4842)
Python opcua 라이브러리를 사용하여 open62541과 유사한 서버 구현
"""
import sys
import time
from opcua import ua, Server

def main():
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4842/open62541/server/")
    server.set_server_name("open62541-style Server (Port 4842)")
    
    # NoSecurity 정책 (취약 버전 테스트용)
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    # 네임스페이스 추가
    uri = "http://open62541.org"
    idx = server.register_namespace(uri)
    
    # open62541 튜토리얼과 유사한 노드 추가
    objects = server.get_objects_node()
    
    # "the answer" 변수 추가 (open62541 튜토리얼과 동일)
    myobj = objects.add_object(idx, "TestFolder")
    the_answer = myobj.add_variable(idx, "the answer", 42)
    the_answer.set_writable()
    
    # 추가 테스트 변수들
    server_time = myobj.add_variable(idx, "ServerTime", time.time())
    server_time.set_writable()
    
    # 서버 시작
    server.start()
    print(f"✅ open62541 스타일 서버가 포트 4842에서 시작되었습니다")
    print(f"   URL: opc.tcp://localhost:4842/open62541/server/")
    print(f"   open62541과 호환되는 Python 구현")
    
    try:
        count = 0
        while True:
            time.sleep(1)
            count += 1
            # 시간 업데이트
            server_time.set_value(time.time())
            
            if count % 10 == 0:
                print(f"[{time.strftime('%H:%M:%S')}] 서버 실행 중... ({count}초)")
    except KeyboardInterrupt:
        print("\n서버 종료 중...")
    finally:
        server.stop()
        print("✅ 서버 종료됨")

if __name__ == "__main__":
    main()
