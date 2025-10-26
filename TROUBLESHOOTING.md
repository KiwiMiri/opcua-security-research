# 트러블슈팅 가이드

## 🔴 일반적인 문제

### 1. PCAP 파일이 비어있거나 작은 경우 (0-24 bytes)

**원인**: 클라이언트 연결이 없어서 실제 트래픽이 캡처되지 않음

**해결책**:
```bash
# 1. 서버가 정상 실행 중인지 확인
ss -tunlp | grep 484

# 2. 클라이언트로 연결 시도
cd /root/opcua-research
source venv/bin/activate
python3 clients/python/client.py

# 3. 별도 터미널에서 캡처 시작
sudo tcpdump -i any -w /tmp/test.pcap 'tcp port 4840' &
python3 clients/python/client.py
sudo killall tcpdump

# 4. 캡처된 파일 확인
tshark -r /tmp/test.pcap -c 10
```

### 2. "Connection refused" 오류

**원인**: 서버가 시작되지 않았거나 포트가 열리지 않음

**해결책**:
```bash
# 서버 상태 확인
./scripts/stop_all_servers.sh
./scripts/start_all_servers.sh

# 5초 대기 후 재확인
sleep 5
ss -tunlp | grep 484

# 로그 확인
tail -f logs/*.log
```

### 3. tcpdump 권한 오류

**원인**: root 권한 필요

**해결책**:
```bash
# sudo로 실행
sudo ./scripts/capture_all_normal.sh
```

### 4. tshark가 데이터를 찾지 못하는 경우

**원인**: OPC UA 디섹터 미적용 또는 포트 미디코드

**해결책**:
```bash
# 1. Wireshark GUI에서
# - Edit > Preferences > Protocols > OPC UA 활성화
# - Decode As > 포트 4840을 OPC UA로 지정

# 2. 명령줄에서 디섹터 확인
tshark -G protocols | grep -i opc

# 3. 수동 디코딩
tshark -r pcaps/python_normal.pcap -o opcua.tcp.port:4840
```

## 🟡 부분적 문제

### 5. 일부 서버만 작동하는 경우

**확인할 사항**:
- Python, Node.js: 일반적으로 안정적
- open62541: 빌드 확인 필요
- FreeOpcUa: 라이브러리 호환성 확인
- Eclipse Milo: Java 버전 확인 (JDK 17 필요)

**진단**:
```bash
# 각 서버 로그 확인
tail -20 logs/python_server.log
tail -20 logs/nodejs_server.log
tail -20 logs/open62541_server.log

# 프로세스 확인
ps aux | grep -E "(python|node|open62541)" | grep opcua
```

### 6. 포트 충돌

**해결책**:
```bash
# 포트 사용 중인 프로세스 확인
sudo lsof -i :4840
sudo lsof -i :4841

# 프로세스 종료
sudo kill <PID>
```

## 🟢 성공 확인

### 정상 작동 시나리오

1. **서버 시작**:
```bash
./scripts/start_all_servers.sh
# 출력 예: "모든 서버가 시작되었습니다"
```

2. **포트 확인**:
```bash
ss -tunlp | grep 484
# 4840, 4841, 4842, 4843, 4844 포트가 LISTEN 상태
```

3. **클라이언트 연결**:
```bash
python3 clients/python/client.py
# 출력 예: "[Python Server] 연결 성공"
```

4. **캡처 확인**:
```bash
tshark -r pcaps/python_normal.pcap -c 5
# 최소한 몇 개의 패킷이 있어야 함
```

## 📞 추가 도움

### 로그 위치
- `/root/opcua-research/logs/` - 모든 서버 로그
- `/tmp/client_normal.log` - 클라이언트 로그 (정상)
- `/tmp/client_attack.log` - 클라이언트 로그 (공격)

### 유용한 명령어
```bash
# 서버 재시작
./scripts/stop_all_servers.sh && ./scripts/start_all_servers.sh

# 모든 프로세스 종료
pkill -f "opcua" && pkill -f "tcpdump"

# 메모리 및 CPU 사용량
htop

# 네트워크 연결 확인
netstat -an | grep 484
```

### 환경 재설정
```bash
cd /root/opcua-research
rm -rf pcaps/* reports/* logs/*
./setup_environment.sh
```
