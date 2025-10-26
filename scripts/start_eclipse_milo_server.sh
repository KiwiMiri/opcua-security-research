#!/bin/bash
cd /root/opcua-research

echo "Eclipse Milo OPC UA 서버 시작 중..."
cd servers/eclipse-milo/opcua-server
mvn exec:java -Dexec.mainClass="org.eclipse.milo.App" > ../../../logs/eclipse_milo_server.log 2>&1 &
echo $! >> ../../../server_pids.txt
echo "Eclipse Milo 서버 PID: $!"



