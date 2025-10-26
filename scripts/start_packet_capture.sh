#!/bin/bash
cd /root/opcua-research

echo "패킷 캡처 시작 중..."
# OPC UA 기본 포트 4840 캡처
tcpdump -i any -w results/pcap/opcua_capture_$(date +%Y%m%d_%H%M%S).pcap port 4840 &
echo $! > monitoring_pids.txt
echo "패킷 캡처 PID: $!"
