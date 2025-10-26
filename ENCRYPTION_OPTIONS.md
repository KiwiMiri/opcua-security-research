# OPC UA 암호화 옵션 설명

## 🔒 사용 가능한 보안 정책

OPC UA 표준에서는 다음 옵션만 제공합니다:

1. **NoSecurity** - 보안 없음
2. **Basic128Rsa15_Sign** - 서명만 (무결성)
3. **Basic128Rsa15_SignAndEncrypt** - 서명 + 암호화
4. **Basic256_Sign** - 서명만 (무결성)
5. **Basic256_SignAndEncrypt** - 서명 + 암호화
6. **Basic256Sha256_Sign** - 서명만 (무결성, SHA-256)
7. **Basic256Sha256_SignAndEncrypt** - 서명 + 암호화 (SHA-256)

## ❌ 사용 불가능

- **Encryption only** - 암호화만 (존재하지 않음)
- **Signature only** - 이건 있습니다! (_Sign)

## 💡 왜 Encryption만 없나?

OPC UA 표준 설계 원칙:
- **서명 없이는 신뢰할 수 없음**: 암호화해도 발신자를 확인할 수 없음
- **서명과 암호화는 항상 함께**: 안전한 통신의 필수 요소

## 🎯 실험 목적에 맞는 선택

### 현재 상황 (NoSecurity)
- 모든 메시지 평문
- 자격증명 탈취 쉬움
- ✅ 논문용 시연에는 적합

### 암호화 사용 (SignAndEncrypt)
- 모든 메시지 암호화
- 자격증명 보호
- ⚠️ 하지만...
  - 인증서 설정 복잡
  - 복호화 없이 분석 어려움
  - 다운그레이드 공격 시연 불가

## ✅ 결론

**암호화만은 불가능합니다.**

OPC UA는 다음만 제공:
- ❌ NoSecurity (평문)
- ❌ Sign (서명만)
- ✅ **SignAndEncrypt** (서명 + 암호화)

**논문 목적**이라면 현재 상태(NoSecurity + 평문 자격증명)로도 충분합니다!
