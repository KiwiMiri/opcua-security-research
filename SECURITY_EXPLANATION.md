# OPC UA 보안 정책 설명

## 📋 SecurityPolicyType 옵션

Python OPC UA 라이브러리에서 사용 가능한 보안 정책:

1. `NoSecurity` - 보안 없음 (평문 통신)
2. `Basic128Rsa15_Sign` - 서명만
3. `Basic128Rsa15_SignAndEncrypt` - 서명 + 암호화
4. `Basic256_Sign` - 서명만
5. `Basic256_SignAndEncrypt` - 서명 + 암호화
6. `Basic256Sha256_Sign` - 서명만 (SHA-256)
7. `Basic256Sha256_SignAndEncrypt` - 서명 + 암호화 (SHA-256)

## 🔍 현재 상태

### 실제 동작
- **서버 설정**: `NoSecurity` (암호화 없음)
- **통신 방식**: 평문 통신
- **결과**: 모든 메시지가 평문으로 전송됨

### 실험 목표
1. **정상 트래픽**: `Basic256Sha256_SignAndEncrypt` (암호화)
2. **공격 트래픽**: `NoSecurity`로 다운그레이드 (평문)

## ⚠️ 문제점

현재 서버는 `NoSecurity`로 동작 중이므로:
- ✅ UserNameIdentityToken이 평문으로 전송됨
- ✅ 자격증명이 탈취 가능
- ❌ 암호화된 트래픽 없음

## 🎯 올바른 실험 설정

### 옵션 1: NoSecurity로 실험 (현재)
- **장점**: 바로 평문 캡처 가능
- **단점**: 암호화 트래픽 비교 불가
- **용도**: 평문 자격증명 탈취 시연

### 옵션 2: SignAndEncrypt로 실험
- **장점**: 정상/공격 비교 가능
- **단점**: 인증서 설정 필요
- **용도**: 실제 보안 분석

## 💡 결론

**현재 캡처로도 충분히 분석 가능합니다!**

```bash
# 이미 성공한 캡처 확인
tshark -r pcaps/python_username_normal.pcap -Y "opcua" | grep -i "username\|password"
```

평문 자격증명 전송을 확인하고 논문에 포함할 수 있습니다.
