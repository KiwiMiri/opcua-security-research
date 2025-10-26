# 다음 실험 단계 가이드

## 🎯 목표
UserNameIdentityToken + Basic256Sha256로 정상/공격 트래픽 캡처 및 분석

## 📋 실험 순서

### 1. 서버 재시작 (Basic256Sha256 설정)

```bash
# 기존 서버 종료
cd /root/opcua-research
./scripts/stop_all_servers.sh

# 보안 설정된 서버 시작
source venv/bin/activate
python3 servers/python/opcua_server_secure.py &
```

### 2. 정상 트래픽 캡처

```bash
./scripts/capture_normal_python.sh
```

**예상 결과**:
- OpenSecureChannel에서 `SecurityPolicy#Basic256Sha256` 확인
- ActivateSession의 자격증명이 암호화된 blob

### 3. 공격 트래픽 캡처 (MITM 필수)

**주의**: 현재는 MITM 없이 캡처하므로 동일 결과 (Basic256Sha256)

```bash
./scripts/capture_attack_python.sh
```

**MITM 구현 후**:
- OpenSecureChannel에서 `SecurityPolicy#None` 등장
- ActivateSession의 자격증명이 평문으로 노출

### 4. 프레임 분석

```bash
# 후보 프레임 찾기
tshark -r pcaps/python_attack_*.pcap -Y "opcua.ActivateSession" -T fields -e frame.number

# 특정 프레임 분석
./scripts/analyze_frame.sh pcaps/python_attack_XXXXXX.pcap 14
```

### 5. 평문 검색

```bash
# 전체 PCAP에서 평문 검색
strings pcaps/python_attack_*.pcap | grep -iE "password|testuser"

# 헥스 덤프에서 검색
tshark -r pcaps/python_attack_*.pcap -x -Y "frame.number == 14" | grep -i "password"
```

## 🔍 검증 체크리스트

### 정상 캡처
- [ ] OpenSecureChannel에 `SecurityPolicy#Basic256Sha256` 확인
- [ ] ActivateSession의 자격증명이 암호화됨 (blob)
- [ ] 평문으로 username/password 보이지 않음

### 공격 캡처 (MITM 구현 후)
- [ ] OpenSecureChannel에 `SecurityPolicy#None` 등장
- [ ] ActivateSession의 자격증명이 평문으로 노출
- [ ] 헥스 덤프에서 `password123!` 등 확인 가능

## ⚠️ 현재 제한사항

1. **MITM 미구현**: 공격 시나리오를 위한 MITM 프록시가 아직 없음
2. **인증서 문제**: Basic256Sha256 사용 시 인증서가 필요할 수 있음
3. **서버 설정**: 서버에서 Basic256Sha256만 활성화되어야 함

## 🚀 즉시 시도 가능

### 옵션 A: 기본 설정으로 테스트 (SecurityPolicy#None)

```bash
# 기존 서버 사용 (NoSecurity)
./scripts/start_all_servers.sh

# 클라이언트 (UserName/Password)
source venv/bin/activate
python3 clients/python_client_username.py
```

### 옵션 B: Basic256Sha256 시도

```bash
# 보안 서버 시작
python3 servers/python/opcua_server_secure.py &

# 잠시 대기
sleep 3

# 클라이언트 실행
python3 clients/python_client_username.py
```

## 📊 논문용 문구 생성

프레임과 오프셋을 확인한 후:

```bash
./scripts/generate_caption.sh python 14 "0x00E0-0x00F0"
```

## 🛠️ 필요한 추가 작업

1. MITM 프록시 구현 (SecurityPolicy 다운그레이드)
2. 인증서 설정 완료
3. 나머지 구현체 (Node.js, open62541 등) 적용

## 💡 빠른 시작

현재 상태에서 바로 테스트:

```bash
cd /root/opcua-research

# 서버 확인
ss -tunlp | grep 4840

# 클라이언트 실행
source venv/bin/activate
python3 clients/python_client_username.py
```
