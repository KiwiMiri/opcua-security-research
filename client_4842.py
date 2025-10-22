#!/usr/bin/env python3
"""
open62541 서버 클라이언트 (포트 4842)
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import time

def main():
    print("╔═══════════════════════════════════════════════════╗")
    print("║   open62541 서버 클라이언트 (포트 4842)          ║")
    print("╚═══════════════════════════════════════════════════╝")
    print()
    
    client = Client("opc.tcp://localhost:4842/open62541/server/")
    
    try:
        print("🔌 포트 4842 서버에 연결 중...")
        client.connect()
        print("✅ 연결 성공!")
        print()
        
        # 서버 정보
        root = client.get_root_node()
        print(f"📋 Root 노드: {root}")
        print(f"📋 Server 이름: {client.get_server_node().get_browse_name()}")
        print()
        
        # 객체 탐색
        objects = client.get_objects_node()
        print("📁 사용 가능한 객체:")
        for child in objects.get_children():
            name = child.get_browse_name()
            print(f"  • {name}")
            
            # TestFolder 찾기
            if "TestFolder" in str(name) or "Test" in str(name):
                print(f"    → open62541 Test 객체 발견!")
                try:
                    # 하위 변수들 확인
                    for var in child.get_children():
                        var_name = var.get_browse_name()
                        try:
                            value = var.get_value()
                            print(f"      - {var_name} = {value}")
                            
                            # "the answer" 변수 테스트
                            if "answer" in str(var_name).lower():
                                print(f"        → open62541 튜토리얼 변수 확인! ✅")
                        except:
                            print(f"      - {var_name}")
                except:
                    pass
        
        print()
        print("✅ open62541 서버 탐색 완료!")
        
    except Exception as e:
        print(f"❌ 오류: {e}")
        sys.exit(1)
    finally:
        client.disconnect()
        print("🔌 연결 종료")

if __name__ == "__main__":
    main()
