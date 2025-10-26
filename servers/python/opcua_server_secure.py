#!/usr/bin/env python3
"""Python OPC UA 서버 - 정상(암호화) 설정"""
from opcua import ua, Server
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    # 서버 생성
    server = Server()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 보안 정책: Basic256Sha256만 활성화 (정상)
    # 주의: NoSecurity는 포함하지 않음
    server.set_security_policy([ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt])
    
    # 인증서 로드 (있는 경우)
    try:
        server.load_certificate("/root/opcua-research/certs/server-cert.pem")
        server.load_private_key("/root/opcua-research/certs/server-key.pem")
        logger.info("인증서 로드됨")
    except:
        logger.warning("인증서 로드 실패, 암호화 없이 진행")
    
    # 네임스페이스 등록
    idx = server.register_namespace("urn:research:server")
    
    # 디바이스 추가
    objects = server.get_objects_node()
    device = objects.add_object(idx, "ResearchDevice")
    
    # 변수 추가
    device.add_variable(idx, "Temperature", 25.0)
    device.add_variable(idx, "Pressure", 1013.25)
    device.add_variable(idx, "Status", "Running")
    
    # 서버 시작
    server.start()
    logger.info("OPC UA 서버 시작됨 (포트 4840, Basic256Sha256)")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("서버 종료 중...")
        server.stop()

if __name__ == "__main__":
    main()
