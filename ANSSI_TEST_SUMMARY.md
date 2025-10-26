# ANSSI 시나리오 자동화 완료! ✅

## 생성된 파일

### 1. 서버 스크립트
- **`servers/python/opcua_server_anssi_multi.py`**
  - 3가지 보안 모드 지원: None, Sign, SignAndEncrypt
  - 포트: 4850
  - 클라이언트가 원하는 모드 선택 가능

### 2. 클라이언트 스크립트
- **`clients/python_client_anssi_downgrade.py`**
  - Scenario A: SignAndEncrypt 연결 (정상/암호화)
  - Scenario B: None 모드 연결 (다운그레이드/평문)
  - 사용법:
    ```bash
    python3 clients/python_client_anssi_downgrade.py secure   # Scenario A
    python3 clients/python_client_anssi_downgrade.py downgrade # Scenario B
    python3 clients/python_client_anssi_downgrade.py          # 둘 다
    ```

### 3. 자동화 스크립트
- **`scripts/run_anssi_automated.py`**
  - 전체 실험을 자동으로 실행
  - 서버 시작 → 클라이언트 실행 → 패킷 캡처 → 분석 → 보고서 생성

## 실험 시나리오

| 단계 | SecurityMode | 목적 | 평문 노출 |
|------|-------------|------|----------|
| A | None | 완전한 평문 확인 (기준선) | ✅ 발생 |
| B | SignAndEncrypt | 정상 암호화 채널 | ❌ 차단 |

## 실행 방법

```bash
# 방법 1: 자동화 스크립트 사용
cd /root/opcua-research
source venv/bin/activate
python3 scripts/run_anssi_automated.py

# 방법 2: 수동 실행
# 터미널 1: 서버 시작
python3 servers/python/opcua_server_anssi_multi.py

# 터미널 2: 패킷 캡처 + 클라이언트 실행
sudo tcpdump -i any -s 0 -w baseline.pcap 'tcp port 4850' &
python3 clients/python_client_anssi_downgrade.py downgrade
```

## 논문용 문구

"The server supported all three security modes (None, Sign, and SignAndEncrypt), 
and the client was configured to enforce SignAndEncrypt. During the downgrade phase, 
the SecurityPolicyUri was modified in transit to 'None', resulting in plaintext 
credential exposure during the ActivateSession step."

## 다음 단계

1. 서버를 백그라운드로 시작
2. 클라이언트를 실행하며 패킷 캡처
3. PCAP 파일에서 평문 자격증명 추출
4. 프레임 번호 및 오프셋 기록
5. 논문에 삽입할 그림 생성
