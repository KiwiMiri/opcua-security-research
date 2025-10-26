#!/usr/bin/env python3
"""
opcua-asyncio v1.1.8 서버 (Python OPC UA 최신 구현체)
포트: 5843
"""
import asyncio
import sys
from asyncua import Server, ua

async def main():
    server = Server()
    await server.init()
    
    server.set_endpoint("opc.tcp://0.0.0.0:5843/asyncua/server/")
    server.set_server_name("opcua-asyncio v1.1.8 Server (Port 5843)")
    
    # 보안 정책 설정 (NoSecurity - 비교를 위해)
    server.set_security_policy([ua.SecurityPolicyType.NoSecurity])
    
    # 네임스페이스 등록
    uri = "http://examples.asyncua.github.io"
    idx = await server.register_namespace(uri)
    
    # 객체 노드 추가
    objects = server.get_objects_node()
    asyncua_obj = await objects.add_object(idx, "AsyncuaTestObject")
    
    # 변수 추가
    test_var = await asyncua_obj.add_variable(idx, "AsyncuaTestVariable", 42)
    await test_var.set_writable()
    
    version_var = await asyncua_obj.add_variable(idx, "Version", "1.1.8-asyncio")
    await version_var.set_writable()
    
    status_var = await asyncua_obj.add_variable(idx, "ServerStatus", "Running")
    await status_var.set_writable()
    
    print(f"opcua-asyncio v1.1.8 서버가 포트 5843에서 시작되었습니다")
    print(f"URL: opc.tcp://localhost:5843/asyncua/server/")
    print(f"Version: 1.1.8 (Python OPC UA 최신 구현체)")
    print(f"Note: python-opcua v0.98.13의 진화된 후속 버전")
    
    # 서버 시작
    async with server:
        counter = 0
        try:
            while True:
                await asyncio.sleep(1)
                counter += 1
                await test_var.write_value(counter)
        except KeyboardInterrupt:
            pass

if __name__ == "__main__":
    asyncio.run(main())

