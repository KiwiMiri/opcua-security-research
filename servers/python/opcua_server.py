#!/usr/bin/env python3
"""
기본 OPC UA 서버 구현
"""

import asyncio
import logging
from opcua import Server, ua

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OPCUAServer:
    def __init__(self, endpoint="opc.tcp://0.0.0.0:4840/freeopcua/server/"):
        self.server = Server()
        self.server.set_endpoint(endpoint)
        self.server.set_server_name("OPC UA Research Server")
        
        # 네임스페이스 설정
        self.ns = self.server.register_namespace("http://opcua-research.org")
        
        # 보안 설정 (테스트용)
        self.server.set_security_policy([
            ua.SecurityPolicyType.NoSecurity
        ])
        
    def setup_nodes(self):
        """노드 구조 설정"""
        # 루트 노드
        root = self.server.get_root_node()
        objects = self.server.get_objects_node()
        
        # 디바이스 노드 생성
        device = objects.add_object(self.ns, "ResearchDevice")
        
        # 변수 노드들 추가
        temp_var = device.add_variable(self.ns, "Temperature", 25.0)
        pressure_var = device.add_variable(self.ns, "Pressure", 1013.25)
        status_var = device.add_variable(self.ns, "Status", "Running")
        
        logger.info("노드 구조 설정 완료")
        
    def start(self):
        """서버 시작"""
        try:
            self.setup_nodes()
            self.server.start()
            logger.info(f"OPC UA 서버가 시작되었습니다: {self.server.endpoint}")
            return True
        except Exception as e:
            logger.error(f"서버 시작 실패: {e}")
            return False

def main():
    server = OPCUAServer()
    if server.start():
        try:
            # 서버 실행 유지
            while True:
                import time
                time.sleep(1)
        except KeyboardInterrupt:
            logger.info("서버 종료 중...")
            server.server.stop()

if __name__ == "__main__":
    main()
