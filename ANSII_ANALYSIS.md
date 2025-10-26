# ANSSI 논문 핵심 요약 및 실험 설계

## 🔍 ANSSI 논문의 핵심 발견

### "Counter-Intuitive" 결과

> "Even when the SecureChannel is negotiated with SignAndEncrypt,
> the UserNameIdentityToken.Password field may still appear in plaintext
> when a downgrade or renegotiation occurs."

**직관**: "암호화되어 있으면 안전하다"
**현실**: "명세상 구조적으로 평문 노출 가능"

## 📊 명세 분석 결과

### OPC UA 구조적 문제

1. **SecureChannel 계층** (암호화 담당)
   - 하위 계층만 보호 (전송 보호)
   - 상위 계층은 별도 보호 없음

2. **Session 계층** (인증 담당)
   - UserIdentityToken 전송
   - 암호화 보호 의존 (SecureChannel에 의존)

3. **재협상 문제**
   - 채널 재협상 시 세션 유지 가능
   - SecurityPolicy 변경 가능 (암호화 → 평문)

## ⚙️ 올바른 실험 순서

### 필요 조건

1. **초기 설정**: SignAndEncrypt (암호화 채널)
2. **채널 재협상**: Renew 요청
3. **다운그레이드**: SecurityPolicy → None
4. **평문 노출**: ActivateSession에서 확인

### 현재 실험의 문제점

❌ 현재: NoSecurity로 시작
- 암호화 단계를 생략
- "암호화되어도 평문 노출" 증명 불가

✅ 필요: SignAndEncrypt → 다운그레이드 → None
- "암호화되어 있는데도 평문 노출" 증명 가능

## 🎯 ANSSI 연구 재현을 위한 단계

### 1단계: 암호화 채널 설정
```
서버: Basic256Sha256_SignAndEncrypt
클라이언트: SignAndEncrypt 모드로 연결
```

### 2단계: 채널 재협상
```
공격자: OpenSecureChannel (RequestType=Renew)
        SecurityPolicyUri = None 변경
```

### 3단계: 평문 노출 확인
```
ActivateSession: UserNameIdentityToken.Password
→ 평문으로 전송됨 확인
```

### 4단계: 비교 분석
```
정상: Basic256Sha256 → 암호화된 blob
공격: None → 평문 노출
```

## 💡 실험 설계 포인트

### ANSSI가 보여준 것

| 단계 | 개발자 직관 | 명세 실제 동작 | 결과 |
|------|------------|--------------|------|
| 초기 | "암호화되면 안전" | SignAndEncrypt 적용 | ✅ 안전 |
| 재협상 | "세션 재설정 필수" | 세션 유지 가능 | ⚠️ 취약 |
| 다운그레이드 | "암호화 유지" | None으로 변경 가능 | ❌ 위험 |
| 자격증명 | "암호화됨" | 평문으로 전송 | ❌ 누출 |

### 핵심 메시지

**"구조적 취약점이 아닌 명세상 허용된 동작"**

- 버그가 아님
- 명세가 허용하는 동작
- 개발자 직관과 다름

## 🚀 실험 재설계 필요

### 현재 상태
```
NoSecurity → 평문 전송
(암호화 없이 평문)
```

### 필요 상태 (ANSSI 재현)
```
SignAndEncrypt → 다운그레이드 → None
(암호화 → 평문으로 변경)
```

## 📝 논문용 설명 문구

**ANSSI 연구 재현**:
"초기 SecureChannel을 SignAndEncrypt로 협상한 후, 채널 재협상 시 SecurityPolicy를 None으로 강제 다운그레이드한 결과, ActivateSession의 UserNameIdentityToken.Password 필드가 평문으로 전송되는 것을 확인하였다."

**현재 실험 한계**:
"현재 실험 환경은 NoSecurity 설정으로 시작하여 평문 전송을 확인했으나, ANSSI 논문에서 지적한 '암호화 상태에서 다운그레이드로 인한 평문 노출' 시나리오는 아직 재현하지 못했다."
