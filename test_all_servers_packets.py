#!/usr/bin/env python3
"""
각 서버에 연결하여 OpenSecureChannel 패킷 캡처
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import socket
import time

def capture_opn_packet(server_port, server_name):
    """OPN 패킷을 직접 캡처"""
    print(f"\n{'='*70}")
    print(f"Testing: {server_name} (Port {server_port})")
    print('='*70)
    
    try:
        # Raw socket으로 연결
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('localhost', server_port))
        
        # HEL 메시지 전송
        hel_msg = bytearray([
            0x48, 0x45, 0x4C, 0x46,  # "HELF"
            0x00, 0x00, 0x00, 0x00,  # Message size (will be filled)
            0x00, 0x00, 0x00, 0x00,  # Protocol version
            0xFF, 0xFF, 0xFF, 0x7F,  # Receive buffer size
            0xFF, 0xFF, 0xFF, 0x7F,  # Send buffer size
            0x00, 0x00, 0x00, 0x00,  # Max message size
            0x00, 0x00, 0x00, 0x00,  # Max chunk count
        ])
        
        # Endpoint URL
        endpoint_url = f"opc.tcp://localhost:{server_port}"
        url_bytes = endpoint_url.encode('utf-8')
        url_len = len(url_bytes)
        
        hel_msg.extend([url_len & 0xFF, (url_len >> 8) & 0xFF, 0x00, 0x00])
        hel_msg.extend(url_bytes)
        
        # Message size 업데이트
        msg_size = len(hel_msg)
        hel_msg[4:8] = msg_size.to_bytes(4, 'little')
        
        print("\n[1] Sending HEL message...")
        sock.send(hel_msg)
        
        # ACK 응답 받기
        ack = sock.recv(1024)
        print(f"[2] Received ACK ({len(ack)} bytes)")
        print(f"    Type: {ack[:4]}")
        
        # OPN 메시지 전송
        print("\n[3] Sending OPN message...")
        
        # 실제 클라이언트가 보내는 OPN 메시지를 캡처하기 위해
        # python-opcua 클라이언트 사용
        sock.close()
        
        # 이제 실제 클라이언트로 연결
        if server_port == 4840:
            url = "opc.tcp://localhost:4840/S2OPC/server/"
        elif server_port == 4841:
            url = "opc.tcp://localhost:4841/freeopcua/server/"
        else:
            url = "opc.tcp://localhost:4842/open62541/server/"
        
        print(f"    Connecting with opcua.Client to: {url}")
        client = Client(url)
        client.connect()
        
        print(f"[4] Connection successful!")
        print(f"    SecurityPolicy used: (check packet capture)")
        
        client.disconnect()
        print(f"[5] Disconnected")
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()

# 각 서버 테스트
servers = [
    (4840, "S2OPC v1.4.0"),
    (4841, "Python OPC UA v0.98.13"),
    (4842, "open62541 v1.3.8"),
]

print("="*70)
print("Packet Capture Test for All Servers")
print("="*70)

for port, name in servers:
    capture_opn_packet(port, name)
    time.sleep(1)

print("\n" + "="*70)
print("All tests completed!")
print("="*70)
print("\nCheck the debug_proxy.log for packet details")

