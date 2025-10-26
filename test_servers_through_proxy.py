#!/usr/bin/env python3
"""
각 서버에 프록시를 통해 연결하여 SecurityPolicy 확인
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import socket
import threading
import time

captured_packets = {}

def simple_proxy(listen_port, target_port, server_name):
    """간단한 프록시 - OPN 패킷 캡처"""
    global captured_packets
    captured_packets[server_name] = []
    
    def handle_connection(client_sock):
        try:
            server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            server_sock.connect(('localhost', target_port))
            
            def forward(src, dst, direction):
                try:
                    while True:
                        data = src.recv(4096)
                        if not data:
                            break
                        
                        # OPN 메시지 캡처
                        if data[:3] == b'OPN':
                            captured_packets[server_name].append({
                                'direction': direction,
                                'data': data,
                                'hex': ' '.join(f'{b:02x}' for b in data[:200])
                            })
                        
                        dst.sendall(data)
                except:
                    pass
            
            t1 = threading.Thread(target=forward, args=(client_sock, server_sock, "C->S"))
            t2 = threading.Thread(target=forward, args=(server_sock, client_sock, "S->C"))
            t1.daemon = True
            t2.daemon = True
            t1.start()
            t2.start()
            t1.join(timeout=5)
            t2.join(timeout=5)
            
        except Exception as e:
            pass
        finally:
            client_sock.close()
            server_sock.close()
    
    # 프록시 서버 시작
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('localhost', listen_port))
    server.listen(1)
    server.settimeout(10)
    
    try:
        client_sock, _ = server.accept()
        handle_connection(client_sock)
    except:
        pass
    finally:
        server.close()

# 프록시 설정
proxies = [
    (14840, 4840, "S2OPC"),
    (14841, 4841, "Python-OPC-UA"),
    (14842, 4842, "open62541"),
]

print("="*70)
print("Security Policy Detection via Proxy")
print("="*70)
print()

for listen_port, target_port, name in proxies:
    print(f"\nTesting {name}...")
    print(f"  Proxy: localhost:{listen_port} -> localhost:{target_port}")
    
    # 프록시 시작 (백그라운드)
    proxy_thread = threading.Thread(
        target=simple_proxy,
        args=(listen_port, target_port, name)
    )
    proxy_thread.daemon = True
    proxy_thread.start()
    
    time.sleep(0.5)  # 프록시 준비 대기
    
    # 클라이언트 연결
    try:
        if target_port == 4840:
            url = f"opc.tcp://localhost:{listen_port}/S2OPC/server/"
        elif target_port == 4841:
            url = f"opc.tcp://localhost:{listen_port}/freeopcua/server/"
        else:
            url = f"opc.tcp://localhost:{listen_port}/open62541/server/"
        
        client = Client(url)
        client.connect()
        print(f"  Connected successfully!")
        client.disconnect()
        
    except Exception as e:
        print(f"  Connection failed: {e}")
    
    proxy_thread.join(timeout=2)
    time.sleep(0.5)

# 결과 분석
print("\n" + "="*70)
print("Captured OPN Packets Analysis")
print("="*70)

for server_name in ["S2OPC", "Python-OPC-UA", "open62541"]:
    print(f"\n{server_name}:")
    print("-"*70)
    
    packets = captured_packets.get(server_name, [])
    
    if not packets:
        print("  No OPN packets captured")
        continue
    
    for i, pkt in enumerate(packets, 1):
        print(f"\n  Packet #{i} ({pkt['direction']}):")
        
        data = pkt['data']
        hex_str = pkt['hex']
        
        # SecurityPolicy URI 추출
        try:
            # OPN 메시지 구조: OPNF + size + channel_id + policy_uri_len + policy_uri + ...
            if b'SecurityPolicy' in data:
                start = data.find(b'http://opcfoundation.org/UA/SecurityPolicy#')
                if start != -1:
                    end = data.find(b'\x00', start)
                    if end != -1:
                        policy = data[start:end].decode('utf-8')
                        print(f"    SecurityPolicy: {policy}")
                        
                        if '#None' in policy:
                            print(f"    [!] NO SECURITY - Plain text communication!")
                        elif '#Basic' in policy:
                            print(f"    [+] Security enabled: {policy.split('#')[1]}")
        except:
            pass
        
        # HEX dump (첫 100바이트)
        print(f"    HEX (first 100 bytes):")
        for j in range(0, min(100, len(data)), 16):
            chunk = data[j:j+16]
            hex_part = ' '.join(f'{b:02x}' for b in chunk)
            ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
            print(f"      {j:04x}: {hex_part:48s} {ascii_part}")

print("\n" + "="*70)
print("Test completed!")
print("="*70)

