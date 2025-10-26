#!/bin/bash
cd /root/opcua-research
source venv/bin/activate
python3 - <<'PY'
from opcua import Client
import time

servers = [
    ("opc.tcp://localhost:4840/freeopcua/server/", "Python Server"),
    ("opc.tcp://localhost:4841/UA/ResearchServer", "Node.js Server"),
]

for endpoint, name in servers:
    try:
        c = Client(endpoint)
        c.connect()
        print(f"[{name}] 연결 성공")
        time.sleep(1)
        c.disconnect()
    except Exception as e:
        print(f"[{name}] 연결 실패: {e}")
PY
