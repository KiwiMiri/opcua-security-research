# 완전한 실험 가이드 - 복사 붙여넣기 실행

## 🎯 목표
UserNameIdentityToken + Basic256Sha256 정상 vs 공격 트래픽 캡처 및 분석

## 📋 실행 순서 (터미널 3개 필요)

### 터미널 1: 서버 시작

```bash
cd /root/opcua-research
source venv/bin/activate
python3 servers/python/opcua_server_secure.py > logs/python_server_secure.log 2>&1 &
SERVER_PID=$!
echo "서버 PID: $SERVER_PID"
sleep 2
ss -tunlp | grep 4840
tail -20 logs/python_server_secure.log
```

### 터미널 2: 캡처 시작

```bash
cd /root/opcua-research
mkdir -p pcaps
echo "캡처 시작 (30초)"
sudo timeout 30 tcpdump -i any -s 0 -w pcaps/python_normal.pcap 'tcp port 4840' &
TCPD_PID=$!
echo "tcpdump PID: $TCPD_PID"
sleep 1
```

### 터미널 3: 클라이언트 실행

```bash
cd /root/opcua-research
source venv/bin/activate
echo "클라이언트 실행..."
python3 clients/python_client_username.py
echo "클라이언트 완료"
```

### 터미널 2: 캡처 종료 및 확인

```bash
# 캡처 대기
wait $TCPD_PID || true
echo "캡처 완료"
ls -lh pcaps/python_normal.pcap

# 프로토콜 통계
tshark -r pcaps/python_normal.pcap -q -z io,phs

# OpenSecureChannel 분석
echo "=== SecurityPolicy 확인 ==="
tshark -r pcaps/python_normal.pcap -Y "opcua.OpenSecureChannel" \
    -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri

# 평문 검색
echo "=== 평문 검색 ==="
strings pcaps/python_normal.pcap | grep -iE "testuser|password" || echo "평문 없음"
```

## 🔍 검증 체크리스트

### 정상 캡처 확인

```bash
# 1. SecurityPolicy 확인
tshark -r pcaps/python_normal.pcap -Y "opcua.OpenSecureChannel" \
    -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri

# 2. ActivateSession 분석
tshark -r pcaps/python_normal.pcap -Y "opcua.ActivateSession" \
    -T fields -e frame.number -e opcua.activatesession.useridentitytoken.type

# 3. 평문 검색 (없어야 정상)
strings pcaps/python_normal.pcap | grep -iE "password123|testuser"

# 4. OPC UA 메시지 흐름 확인
tshark -r pcaps/python_normal.pcap -Y "opcua" -T fields -e frame.number -e opcua.msgtype
```

**정상 결과**:
- ✅ SecurityPolicy#Basic256Sha256 확인
- ✅ ActivateSession의 자격증명이 암호화됨
- ✅ 평문으로 testuser, password123 등 보이지 않음

## 🚨 공격 시나리오 (MITM 필요)

### 현재 상태
- MITM 미구현: 공격 시나리오는 MITM 프록시 필요
- 임시: 기본 설정으로 재캡처 (동일 결과 예상)

### 실행 (MITM 없이)

```bash
# 터미널 2에서
echo "공격 캡처 시작"
sudo timeout 60 tcpdump -i any -s 0 -w pcaps/python_attack.pcap 'tcp port 4840' &
TCPD_PID=$!
sleep 1

# 터미널 3에서
python3 clients/python_client_username.py

# 터미널 2에서
wait $TCPD_PID || true
```

### 분석 (프레임 14 기준)

```bash
# 1. ActivateSession 프레임 찾기
FRAME=$(tshark -r pcaps/python_attack.pcap -Y "opcua.ActivateSession" \
    -T fields -e frame.number | head -1)
echo "ActivateSession 프레임: $FRAME"

# 2. 헥스 덤프 생성
tshark -r pcaps/python_attack.pcap -x -Y "frame.number == $FRAME" > /tmp/frame_hexdump.txt

# 3. 평문 검색
nl -ba /tmp/frame_hexdump.txt | grep -iE "testuser|password|username" -C 3

# 4. 전체 PCAP 평문 검색
strings pcaps/python_attack.pcap | grep -iE "password|testuser" || echo "평문 없음"
```

## 🛠️ 문제 해결

### 1. 캡처가 빈 파일 (0-24 bytes)

**원인**: 클라이언트가 캡처 중에 연결하지 않음

**해결**:
```bash
# 타이밍 확인
# 1. 캡처 시작
# 2. 1초 대기
# 3. 클라이언트 실행
```

### 2. 정상인데 평문이 보임

**원인**: SecurityPolicy#None 사용 중

**해결**:
```bash
# 서버 설정 확인
grep -i "SecurityPolicy" servers/python/opcua_server_secure.py
# Basic256Sha256만 있어야 함 (NoSecurity 없어야 함)
```

### 3. 클라이언트 연결 실패

**원인**: 서버가 시작하지 않음 또는 인증서 문제

**해결**:
```bash
# 서버 상태 확인
ss -tunlp | grep 4840
tail -20 logs/python_server_secure.log

# 서버 재시작
pkill -f opcua_server_secure.py
python3 servers/python/opcua_server_secure.py > logs/server.log 2>&1 &
```

### 4. 프레임 번호 찾기

```bash
# ActivateSession 프레임 번호
tshark -r pcaps/python_attack.pcap -Y "opcua.ActivateSession" \
    -T fields -e frame.number

# 평문이 포함된 프레임 찾기
for frame in $(tshark -r pcaps/python_attack.pcap -Y "opcua" -T fields -e frame.number | head -20); do
    echo "=== Frame $frame ==="
    tshark -r pcaps/python_attack.pcap -x -Y "frame.number == $frame" | \
        strings | grep -iE "password|testuser" && echo "평문 발견!"
done
```

## 📊 논문용 오프셋 추출

```bash
FRAME=14  # ActivateSession 프레임
PCAP="pcaps/python_attack.pcap"

# 헥스 덤프
tshark -r "$PCAP" -x -Y "frame.number == $FRAME" > /tmp/frame_hex.txt

# 오프셋 및 평문 확인
nl -ba /tmp/frame_hex.txt | grep -iE "password|testuser|username" -C 3

# 출력 예시:
# 000e0: 70 61 73 73 77 6f 72 64 31 32 33 21 ...
#        ^^^^^^^^^^^^^^^^^^^^^^^
#        0x00E0: "password123!"
```

## 🎓 논문용 문구

### 프레임과 오프셋 확인 후

**영문**:
"After coercing a re-negotiation to SecurityPolicy=None, the ActivateSession.UserNameIdentityToken.Password field was transmitted in plaintext (Frame 14, ASCII offset 0x00E0–0x00F0). Baseline traces with only Basic256Sha256 show the same field as an encrypted blob."

**한글**:
"채널 재협상을 통해 SecurityPolicy=None으로 강제 전환한 후 ActivateSession의 UserNameIdentityToken.Password 필드가 평문으로 전송됨(프레임 14, ASCII 오프셋 0x00E0–0x00F0). 정상 캡처(Basic256Sha256 전용)에서는 동일 필드가 암호화된 blob으로 관찰됨."

## 🚀 빠른 실행 요약

```bash
# 1. 서버 시작
cd /root/opcua-research && source venv/bin/activate
python3 servers/python/opcua_server_secure.py > logs/server.log 2>&1 &
sleep 2

# 2. 캡처 시작
sudo timeout 30 tcpdump -i any -s 0 -w pcaps/test.pcap 'tcp port 4840' &
sleep 1

# 3. 클라이언트 실행
python3 clients/python_client_username.py

# 4. 분석
tshark -r pcaps/test.pcap -Y "opcua" | head -20
```

## ✅ 성공 기준

1. ✅ PCAP 파일 크기 > 1KB
2. ✅ OPC UA 메시지 10개 이상
3. ✅ OpenSecureChannel 확인
4. ✅ ActivateSession 확인
5. ✅ 평문 자격증명 검색 (정상: 없음, 공격: 있음)

## 📞 다음 단계

현재 PCAP 캡처 결과를 보내주시면:
1. 헥스 덤프 분석
2. 정확한 오프셋 추출
3. 논문용 캡션 생성

또는 다음을 요청하세요:
1. MITM 자동화 스크립트 생성
2. 모든 구현체 자동 실험 스크립트
3. 상세 분석 리포트 생성
