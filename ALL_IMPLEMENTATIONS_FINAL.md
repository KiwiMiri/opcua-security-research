# 최종 OPC UA 구현체 상태

## ✅ 완전 작동 (5개 구현체)

| 구현체 | 언어 | 포트 | 상태 | 특징 |
|--------|------|------|------|------|
| **Python-opcua** | Python | 4840 | ✅ | 기본 허용 |
| **Node-opcua** | Node.js | 4841 | ✅ | 기본 허용 |
| **FreeOpcUa** | Python | 4842 | ✅ | 기본 허용 |
| **open62541** | C | 4840 | ✅ | ⚠️ "This can leak credentials" 경고 |
| **Eclipse Milo** | Java | 4844 | ✅ | JAR 서명 문제 해결됨 |

## ⚠️ 부분 구현 (1개)

| 구현체 | 언어 | 포트 | 상태 | 문제 |
|--------|------|------|------|------|
| **S2OPC** | C | - | ⚠️ 클론 완료 | CMake 의존성 문제로 빌드 어려움 |

## 결론

**5개 구현체로 ANSSI 시나리오 충분히 재현 가능!**

- Python (2개)
- Node.js (1개)  
- C (1개)
- Java (1개)

총 5개 언어, 5개 구현체로 다양성 확보!

## S2OPC 참고
- GitLab: https://gitlab.com/systerel/S2OPC
- Apache 2.0 라이선스
- ANSSI CSPN 인증받음
- Systerel에서 개발 및 지원

## 다음 단계
5개 구현체로 ANSSI 시나리오 (평문 자격증명 재현) 진행 시작
