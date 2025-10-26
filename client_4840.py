#!/usr/bin/env python3
"""
S2OPC 서버 클라이언트 (포트 4840)
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import time

def main():
    print("╔═══════════════════════════════════════════════════╗")
    print("║     S2OPC 서버 클라이언트 (포트 4840)            ║")
    print("╚═══════════════════════════════════════════════════╝")
    print()
    
    client = Client("opc.tcp://localhost:4840/S2OPC/server/")
    
    try:
        print("🔌 포트 4840 서버에 연결 중...")
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
            
            # S2OPC_Demo 객체 찾기
            if "S2OPC_Demo" in str(name) or "Demo" in str(name):
                print(f"    → S2OPC Demo 객체 발견!")
                try:
                    # 하위 변수들 확인
                    for var in child.get_children():
                        var_name = var.get_browse_name()
                        try:
                            value = var.get_value()
                            print(f"      - {var_name} = {value}")
                        except:
                            print(f"      - {var_name}")
                except:
                    pass
        
        print()
        print("✅ S2OPC 서버 탐색 완료!")
        
    except Exception as e:
        print(f"❌ 오류: {e}")
        sys.exit(1)
    finally:
        client.disconnect()
        print("🔌 연결 종료")

if __name__ == "__main__":
    main()
