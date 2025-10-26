# ANSSI 시나리오 설정 현황

## 문제 요약
사용자가 지적한 대로, 현재 테스트 환경은 ANSSI 시나리오와 맞지 않습니다:

### 현재 상태 (잘못됨)
1. ✅ 서버가 SignAndEncrypt + None 엔드포인트 제공 → OK
2. ❌ 클라이언트가 Anonymous로 연결 → **실패**
3. ❌ 클라이언트가 자격증명을 평문으로 전송하는 것으로 보임 (로그 확인 필요)
4. ❌ 초기 "정상" 연결이 암호화되지 않음 → **ANSSI 시나리오와 불일치**

### ANSSI 시나리오 요구사항
1. ✅ 서버: SignAndEncrypt + None 모두 제공
2. ❌ 정상: SignAndEncrypt로 연결 + UserNameIdentityToken → **자격증명 암호화**
3. ❌ 공격: None으로 다운그레이드 → **자격증명 평문 노출**
4. ❌ 두 pcap 비교: 암호화 vs 평문 차이 확인 → **미완료**

## 핵심 발견
**python-opcua 라이브러리는 UserNameIdentityToken을 지원하지만, 암호화 정책을 강제하는 방법이 명확하지 않습니다.**

로그 출력:
```
WARNING:opcua.client.client:Sending plain-text password
```

이것은 클라이언트가 SignAndEncrypt 정책을 설정했더라도, 실제로 평문으로 전송하고 있다는 의미일 수 있습니다.

## 다음 단계
1. PCAP 캡처하여 실제 전송 내용 확인
2. 다른 구현체(Node.js, C)에서 동일 테스트
3. python-opcua의 보안 정책 강제 방법 문서 확인

## 테이블 상태
현재 `sft-06.tsv`는 Anonymous 인증 상태로 측정된 데이터로 채워져 있으며, 이것은 ANSSI 시나리오와 맞지 않습니다.

**올바른 데이터 수집을 위해서는:**
- 암호화 정책이 활성화된 상태
- UserNameIdentityToken 사용
- 실제 PCAP 분석으로 평문/암호화 여부 확인
