#!/usr/bin/env python3
"""
실제 open62541 C 서버 패킷 캡처
"""
import sys
sys.path.insert(0, '/root/opcua-research/python-opcua-env/lib/python3.10/site-packages')

from opcua import Client
import socket
import threading
import time

captured_opn = []

def proxy_4850():
    """포트 14850 -> 4850 프록시"""
    def handle(client_sock):
        try:
            server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            server_sock.connect(('localhost', 4850))
            
            def forward(src, dst, name):
                try:
                    while True:
                        data = src.recv(4096)
                        if not data:
                            break
                        
                        if data[:3] == b'OPN':
                            print(f"\n[{name}] OPN packet captured!")
                            print(f"Size: {len(data)} bytes")
                            
                            # SecurityPolicy 추출
                            if b'SecurityPolicy' in data:
                                start = data.find(b'http://opcfoundation.org/UA/SecurityPolicy#')
                                if start != -1:
                                    end = data.find(b'\x00', start)
                                    if end != -1:
                                        policy = data[start:end].decode('utf-8')
                                        print(f"SecurityPolicy: {policy}")
                                        captured_opn.append({
                                            'direction': name,
                                            'policy': policy,
                                            'data': data
                                        })
                            
                            # HEX dump
                            print("HEX (first 100 bytes):")
                            for i in range(0, min(100, len(data)), 16):
                                chunk = data[i:i+16]
                                hex_part = ' '.join(f'{b:02x}' for b in chunk)
                                ascii_part = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
                                print(f"  {i:04x}: {hex_part:48s} {ascii_part}")
                        
                        dst.sendall(data)
                except:
                    pass
            
            t1 = threading.Thread(target=forward, args=(client_sock, server_sock, "CLIENT->SERVER"))
            t2 = threading.Thread(target=forward, args=(server_sock, client_sock, "SERVER->CLIENT"))
            t1.daemon = True
            t2.daemon = True
            t1.start()
            t2.start()
            t1.join(timeout=10)
            t2.join(timeout=10)
        except Exception as e:
            print(f"Proxy error: {e}")
        finally:
            client_sock.close()
            try:
                server_sock.close()
            except:
                pass
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('localhost', 14850))
    server.listen(1)
    server.settimeout(15)
    
    try:
        client_sock, _ = server.accept()
        handle(client_sock)
    except:
        pass
    finally:
        server.close()

print("="*70)
print("Real open62541 v1.3.8 C Server - Packet Capture")
print("="*70)
print()

# 프록시 시작
proxy_thread = threading.Thread(target=proxy_4850)
proxy_thread.daemon = True
proxy_thread.start()
time.sleep(1)

print("Proxy started: localhost:14850 -> localhost:4850")
print("Connecting...")
print()

try:
    client = Client("opc.tcp://localhost:14850")
    client.connect()
    print("Connected successfully!")
    print()
    
    # 서버 정보 읽기
    print("Reading server info...")
    server_node = client.get_server_node()
    print(f"Server: {server_node.get_browse_name()}")
    print()
    
    client.disconnect()
    print("Disconnected")
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

proxy_thread.join(timeout=2)

print()
print("="*70)
print("Analysis Results")
print("="*70)
print()

if captured_opn:
    print(f"Captured {len(captured_opn)} OPN packet(s)")
    print()
    for i, pkt in enumerate(captured_opn, 1):
        print(f"[{i}] {pkt['direction']}")
        print(f"    SecurityPolicy: {pkt['policy']}")
        if '#None' in pkt['policy']:
            print(f"    [VULNERABLE] No encryption!")
else:
    print("No OPN packets captured")

print()
print("="*70)

