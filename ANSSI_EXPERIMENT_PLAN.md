# ANSSI 시나리오 재현 실험 계획

## 🎯 목표
초기 SignAndEncrypt → 재협상으로 None 다운그레이드 → 평문 유출 확인

## 📋 두 가지 접근 방법

### 방법 A: 빠른 증거 (추천)
**서버에 암호화 + None 엔드포인트 함께 노출**

장점:
- ✅ 구현 간단
- ✅ 빠르게 증거 확보
- ✅ 개념 검증 가능

단계:
1. 서버: Basic256Sha256 + NoSecurity
2. 클라이언트: SignAndEncrypt로 연결
3. 재협상: None으로 전환
4. 확인: ActivateSession 평문 검증

### 방법 B: 정공법 MITM (정밀 재현)
**실제 MITM 프록시로 재협상 조작**

장점:
- ✅ ANSSI 논문과 동일
- ✅ 공격 시나리오 완벽 재현

단점:
- ⚠️ 구현 복잡
- ⚠️ 양쪽 채널 암호화 처리 필요

## 🚀 방법 A 실행 계획

### 1. 서버 설정 변경

```python
# servers/python/opcua_server_anssi.py
from opcua import ua, Server

server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840")

# 핵심: 두 정책 모두 활성화
server.set_security_policy([
    ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt,
    ua.SecurityPolicyType.NoSecurity  # 다운그레이드용
])
```

### 2. 정상 캡처 (SignAndEncrypt)

```bash
# 캡처 시작
sudo timeout 30 tcpdump -i any -w pcaps/anssi_normal.pcap 'tcp port 4840' &

# 클라이언트 (SignAndEncrypt 모드)
python3 clients/python_client_username_encrypted.py

# 확인
tshark -r pcaps/anssi_normal.pcap -Y "opcua.OpenSecureChannel" \
    -T fields -e frame.number -e opcua.opensecurechannel.securitypolicyuri
```

### 3. 공격 캡처 (다운그레이드)

```bash
# 다운그레이드 실행
python3 clients/python_client_username_none.py

# 확인
tshark -r pcaps/anssi_attack.pcap -Y "opcua.ActivateSession" \
    -x | grep -i "testuser\|password"
```

## 📊 예상 결과

### 정상 캡처
- OpenSecureChannel: Basic256Sha256_SignAndEncrypt
- ActivateSession: 암호화된 blob (평문 없음)

### 공격 캡처  
- OpenSecureChannel: NoSecurity (다운그레이드)
- ActivateSession: 평문 전송 (testuser, password123!)

## ✅ 검증 체크리스트

- [ ] 정상에서 Basic256Sha256 확인
- [ ] 정상에서 평문 없음 확인
- [ ] 공격에서 None 확인
- [ ] 공격에서 평문 확인
- [ ] 프레임 번호 및 오프셋 기록
- [ ] 헥스 덤프 생성
- [ ] 논문용 캡션 작성

## 🛡️ 윤리/법적 준수

- ✅ 격리된 테스트 환경만 사용
- ✅ 프로덕션 시스템 미사용
- ✅ Responsible Disclosure 준수
