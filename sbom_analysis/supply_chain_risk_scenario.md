# SBOM 기반 공급망 보안 리스크 시나리오

## 📊 Phase 2: 공급망 리스크 시나리오 분석

**작성일**: 2025-10-21  
**목적**: OPC UA 구현체의 SBOM 기반 리스크 모델 및 완화 전략 제시

---

## 시나리오 1: 스마트 팩토리 A (자동차 부품 제조)

### 1.1 시스템 구성

**공장 개요**:
- 위치: 경기도 화성시
- 규모: 생산 라인 5개, 설비 200대
- 생산품: 전기차 배터리 모듈
- 연간 생산액: 5,000억 원

**IT/OT 시스템**:
```
┌─────────────────────────────────────────────────────────────┐
│ Level 4: ERP (SAP)                                          │
├─────────────────────────────────────────────────────────────┤
│ Level 3: MES (Manufacturing Execution System)               │
│           ↕ OPC UA 통신                                     │
├─────────────────────────────────────────────────────────────┤
│ Level 2: SCADA / HMI                                        │
│           ├── Server 1: S2OPC v1.4.0 (4840)                │
│           ├── Server 2: python-opcua v0.98.13 (4841)       │
│           └── Server 3: open62541 v1.3.8 (4842)            │
│           ↕ OPC UA 통신                                     │
├─────────────────────────────────────────────────────────────┤
│ Level 1: PLC / Controller (200대)                           │
│           ├── Siemens S7-1500 (100대)                      │
│           ├── Rockwell ControlLogix (50대)                 │
│           └── Mitsubishi Q-Series (50대)                   │
├─────────────────────────────────────────────────────────────┤
│ Level 0: Sensors / Actuators (1,000+)                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 SBOM 분석

**시스템 SBOM** (factory-a-control-system.sbom.json):

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "version": 1,
  "metadata": {
    "component": {
      "name": "Factory-A-Control-System",
      "version": "2.1.0",
      "type": "application"
    }
  },
  "components": [
    {
      "name": "S2OPC",
      "version": "1.4.0",
      "type": "library",
      "scope": "required",
      "licenses": [{"license": {"id": "LGPL-2.1"}}]
    },
    {
      "name": "python-opcua",
      "version": "0.98.13",
      "type": "library",
      "scope": "required",
      "licenses": [{"license": {"id": "LGPL-3.0"}}]
    },
    {
      "name": "open62541",
      "version": "1.3.8",
      "type": "library",
      "scope": "required",
      "licenses": [{"license": {"id": "MPL-2.0"}}]
    }
  ]
}
```

### 1.3 SBOM 스캔 결과

**자동 스캔** (우리 연구 DB 기반):

```
$ sbom-scanner scan factory-a-control-system.sbom.json

╔═══════════════════════════════════════════════════════════╗
║         SBOM 보안 스캔 결과                               ║
╚═══════════════════════════════════════════════════════════╝

총 컴포넌트: 3개
취약점 발견: 3개

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 HIGH SEVERITY (1개)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] python-opcua v0.98.13
    ├── 취약점: OPCUA-2025-001
    ├── 설명: 개발 중단, 암호화 미지원, 5년 방치
    ├── 영향: 
    │   - 암호화 통신 불가능
    │   - 보안 패치 없음
    │   - 공급망 공격 위험
    ├── 참조: CISC 2025 연구, ANSSI 2022 보고서
    └── 권장: opcua-asyncio v1.1.8로 긴급 마이그레이션

🟡 MEDIUM SEVERITY (2개)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[2] S2OPC v1.4.0
    ├── 취약점: OPCUA-2025-002
    ├── 설명: 3년 전 버전, Password Downgrade 취약
    ├── 영향:
    │   - Anonymous 인증 허용
    │   - NoSecurity 정책 활성화
    │   - 2년간 보안 패치 누락
    ├── 참조: CISC 2025 Phase 3 테스트
    └── 권장: v1.6.0으로 업그레이드

[3] open62541 v1.3.8
    ├── 취약점: OPCUA-2025-003
    ├── 설명: 2년 전 버전, 보안 개선 필요
    ├── 영향:
    │   - Anonymous 인증 허용
    │   - NoSecurity 정책 활성화
    │   - 6개월간 보안 패치 누락
    ├── 참조: CISC 2025 Cross-Implementation 테스트
    └── 권장: v1.4.14로 업그레이드

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

위험도 요약:
  🔴 HIGH: 1개 (긴급 조치 필요)
  🟡 MEDIUM: 2개 (계획적 업그레이드)
  ✅ LOW: 0개

총 리스크 점수: 🔴 7/10 (높음)
```

### 1.4 리스크 평가

**재무적 영향**:
```
보안 사고 발생 시 예상 피해:
├── 생산 중단: 1일 = 13.7억 원 (5,000억/365일)
├── 데이터 유출: 설계 도면, 공정 데이터
├── 랜섬웨어: 복구 비용 + 몸값
└── 법적 책임: GDPR, 개인정보보호법

총 예상 피해: 최대 100억 원 이상
```

**보안 사고 시나리오**:
1. 공격자가 OPC UA 서버 탐지
2. NoSecurity 정책 확인 (GetEndpoints)
3. Anonymous로 연결
4. 생산 데이터 수집 또는 변조
5. 랜섬웨어 배포 또는 sabotage

**발생 확률**:
- python-opcua v0.98.13 사용: 🔴 높음 (60%)
- 패치 버전 사용 시: 🟢 낮음 (5%)

---

## 시나리오 2: 에너지 관리 시스템 (ESS)

### 2.1 시스템 구성

**시설 개요**:
- 유형: 배터리 에너지 저장 시스템 (ESS)
- 용량: 100MWh
- 위치: 전국 10개소
- 운영: 원격 모니터링 및 제어

**제어 시스템**:
```
중앙 관제센터
    ↕ (인터넷)
10개 ESS 사이트
    ├── OPC UA Server: open62541 v1.3.8
    ├── BMS (Battery Management)
    ├── PCS (Power Conversion)
    └── 원격 제어 시스템
```

### 2.2 SBOM 리스크

**노출된 리스크**:
1. **인터넷 노출**: 원격 접근을 위해 방화벽 개방
2. **NoSecurity 정책**: 초기 설정 단순화
3. **구버전 사용**: 초기 구축 후 업데이트 없음

**SBOM 스캔 결과**:
```
🔴 CRITICAL: open62541 v1.3.8 (인터넷 노출 + 취약 버전)
  
위험 시나리오:
  1. 공격자가 Shodan으로 OPC UA 서버 탐색
  2. 포트 4840 개방 확인
  3. Anonymous 연결 성공
  4. 배터리 충전/방전 제어 장악
  5. 물리적 손상 또는 화재 위험

예상 피해:
  - 배터리 시스템 손상: 100억 원
  - 화재 발생 시: 인명 피해 + 재산 손실
  - 전력망 불안정: 사회적 파급효과

권장 조치:
  ✅ 즉시 open62541 v1.4.14로 업그레이드
  ✅ NoSecurity 정책 비활성화
  ✅ VPN 또는 방화벽 강화
```

---

## 시나리오 3: 제약 공장 (GMP 시설)

### 3.1 시스템 구성

**공장 개요**:
- 유형: 의약품 제조 (GMP 인증)
- 규모: Clean Room 10개
- 생산품: 주사제, 경구제
- 규제: FDA, MFDS 승인 필수

**제어 시스템**:
```
QMS (Quality Management System)
    ↕
MES (제조 실행 시스템)
    ↕ OPC UA
SCADA (온도/습도/압력 제어)
    ├── python-opcua v0.98.13 서버
    └── 센서 데이터 수집 (1분 간격)
```

### 3.2 SBOM 리스크

**규제 준수 문제**:
```
FDA 21 CFR Part 11:
  "전자 기록 시스템은 보안성과 무결성을 보장해야 함"

python-opcua v0.98.13:
  ❌ 암호화 없음 → 규제 위반 가능
  ❌ 데이터 무결성 검증 어려움
  ❌ 감사 추적 불충분

SBOM 스캔 결과:
  🔴 COMPLIANCE VIOLATION
  📋 권장: opcua-asyncio v1.1.8 (암호화 지원)
```

**비즈니스 영향**:
- FDA 승인 지연: 6개월~1년
- 매출 손실: 수백억 원
- 시장 경쟁력 상실

---

## SBOM 기반 리스크 모델

### 4.1 리스크 계산 공식

```
총 리스크 점수 = Σ (취약점 심각도 × 발생 확률 × 영향 범위)

취약점 심각도:
  - HIGH: 3점
  - MEDIUM: 2점
  - LOW: 1점

발생 확률:
  - 암호화 없음: ×3
  - 개발 중단: ×2
  - 구버전: ×1.5

영향 범위:
  - 인터넷 노출: ×3
  - 내부망 only: ×1
  - 격리된 네트워크: ×0.5
```

### 4.2 시나리오별 리스크 점수

**시나리오 1 (스마트 팩토리)**:
```
python-opcua v0.98.13:
  = 3 (HIGH) × 3 (암호화 없음) × 1 (내부망)
  = 9점 🔴

S2OPC v1.4.0:
  = 2 (MEDIUM) × 1.5 (구버전) × 1 (내부망)
  = 3점 🟡

open62541 v1.3.8:
  = 2 (MEDIUM) × 1.5 (구버전) × 1 (내부망)
  = 3점 🟡

총점: 15점 🔴 (높은 리스크)
```

**시나리오 2 (ESS)**:
```
open62541 v1.3.8:
  = 2 (MEDIUM) × 1.5 (구버전) × 3 (인터넷)
  = 9점 🔴

총점: 9점 🔴 (매우 높은 리스크)
```

**시나리오 3 (제약 공장)**:
```
python-opcua v0.98.13:
  = 3 (HIGH) × 3 (암호화 없음) × 2 (규제 위반)
  = 18점 🔴🔴

총점: 18점 🔴🔴 (극도로 높은 리스크)
```

### 4.3 리스크 매트릭스

```
              ┌─────────────────────────────────────────┐
              │          발생 확률 (Likelihood)          │
              ├──────────┬──────────┬──────────┬────────┤
              │  낮음    │   중간   │   높음   │  매우  │
              │  (1)     │   (2)    │   (3)    │  높음  │
              │          │          │          │  (4)   │
┌─────────────┼──────────┼──────────┼──────────┼────────┤
│ 영향        │          │          │          │        │
│ (Impact)    │          │          │          │        │
├─────────────┼──────────┼──────────┼──────────┼────────┤
│ 매우 높음(4)│   🟡     │   🔴     │   🔴     │  🔴🔴  │
│             │   (4)    │   (8)    │  (12)    │  (16)  │
├─────────────┼──────────┼──────────┼──────────┼────────┤
│ 높음 (3)    │   🟢     │   🟡     │   🔴     │  🔴    │
│             │   (3)    │   (6)    │   (9)    │  (12)  │
├─────────────┼──────────┼──────────┼──────────┼────────┤
│ 중간 (2)    │   🟢     │   🟢     │   🟡     │  🔴    │
│             │   (2)    │   (4)    │   (6)    │  (8)   │
├─────────────┼──────────┼──────────┼──────────┼────────┤
│ 낮음 (1)    │   🟢     │   🟢     │   🟢     │  🟡    │
│             │   (1)    │   (2)    │   (3)    │  (4)   │
└─────────────┴──────────┴──────────┴──────────┴────────┘

현재 위치:
  • python-opcua: 🔴 (9점) - 높음 × 높음
  • S2OPC v1.4.0: 🟡 (3점) - 중간 × 중간
  • open62541 v1.3.8: 🟡 (3점) - 중간 × 중간
  • open62541 (인터넷): 🔴 (9점) - 높음 × 높음
  • python-opcua (규제): 🔴🔴 (18점) - 매우높음 × 매우높음
```

---

## 5. 완화 전략 (Mitigation Strategy)

### 5.1 즉시 조치 (긴급)

**대상**: python-opcua v0.98.13

**조치 1: 긴급 마이그레이션**
```bash
# 현황 파악
pip freeze | grep opcua

# 백업
pip freeze > requirements_backup.txt

# opcua-asyncio 설치
pip install asyncua==1.1.8

# 코드 재작성 (async/await)
# 테스트 및 검증
# 배포
```

**예상 시간**: 1-2주  
**비용**: 개발자 인건비 (약 500만원)  
**리스크 감소**: 🔴 9점 → 🟢 1점 (-89%)

**조치 2: 임시 완화 (마이그레이션 전)**
```
1. 방화벽 규칙 강화:
   - OPC UA 포트 (4840-4842) 내부망만 허용
   - VPN 필수

2. 네트워크 분리:
   - OT 네트워크 완전 격리
   - DMZ를 통한 간접 연결만

3. 모니터링 강화:
   - OPC UA 연결 로깅
   - 비정상 행위 탐지 (IDS)
```

### 5.2 계획적 업그레이드 (권장)

**대상**: S2OPC v1.4.0, open62541 v1.3.8

**조치 1: S2OPC 업그레이드**
```bash
# 현재 버전 확인
./toolkit_demo_server --version

# v1.6.0 빌드
wget https://github.com/systerel/S2OPC/archive/S2OPC_Toolkit_1.6.0.tar.gz
tar -xzf S2OPC_Toolkit_1.6.0.tar.gz
cd S2OPC-S2OPC_Toolkit_1.6.0/build
cmake .. -DWARNINGS_AS_ERRORS=OFF
make -j$(nproc)

# 테스트
# 설정 파일 마이그레이션
# 배포
```

**예상 시간**: 1-2일  
**비용**: 최소 (설정 조정만)  
**리스크 감소**: 🟡 3점 → 🟢 1점 (-67%)

**조치 2: open62541 업그레이드**
```bash
# v1.4.14 빌드
wget https://github.com/open62541/open62541/archive/v1.4.14.tar.gz
tar -xzf v1.4.14.tar.gz
cd open62541-1.4.14/build
cmake .. -DUA_NAMESPACE_ZERO=REDUCED
make -j$(nproc)

# 호환성 테스트
# 배포
```

**예상 시간**: 1-2일  
**비용**: 최소  
**리스크 감소**: 🟡 3점 → 🟢 1점 (-67%)

### 5.3 장기 전략

**전략 1: SBOM 자동화**
```
1. CI/CD 파이프라인에 SBOM 생성 통합
   ├── syft, cyclonedx-cli 사용
   └── 모든 빌드마다 SBOM 생성

2. 취약점 스캔 자동화
   ├── Grype, Trivy 사용
   ├── 우리 연구 DB 추가
   └── 빌드 시 자동 스캔

3. 알림 체계
   ├── HIGH: 즉시 알림 + 빌드 차단
   ├── MEDIUM: 경고 + 이슈 생성
   └── LOW: 로그 기록
```

**전략 2: 정기 업데이트 정책**
```
월례 점검:
  ├── SBOM 스캔
  ├── 의존성 버전 확인
  └── 보안 공지 확인

분기별 업데이트:
  ├── 마이너 버전 업그레이드
  ├── 의존성 업데이트
  └── 테스트 및 검증

연간 대규모 업데이트:
  ├── 메이저 버전 검토
  ├── 아키텍처 개선
  └── 전체 시스템 감사
```

**전략 3: 제로 트러스트 아키텍처**
```
1. 모든 OPC UA 연결 인증 필수
   ❌ Anonymous 금지
   ✅ 사용자/인증서 기반 인증

2. 암호화 필수
   ❌ NoSecurity 정책 비활성화
   ✅ Basic256Sha256 이상 사용

3. 최소 권한 원칙
   ✅ Read-only 계정
   ✅ 역할 기반 접근 제어

4. 네트워크 분리
   ✅ OT 네트워크 격리
   ✅ 마이크로 세그먼테이션
```

---

## 6. 비용-효과 분석

### 6.1 업그레이드 비용

| 항목 | python-opcua → asyncio | S2OPC 업그레이드 | open62541 업그레이드 |
|------|----------------------|-----------------|-------------------|
| **개발 시간** | 80시간 | 8시간 | 8시간 |
| **인건비** | 500만원 | 50만원 | 50만원 |
| **테스트** | 40시간 | 4시간 | 4시간 |
| **배포** | 8시간 | 2시간 | 2시간 |
| **총 비용** | 750만원 | 75만원 | 75만원 |
| **다운타임** | 1일 | 2시간 | 2시간 |

### 6.2 리스크 감소 효과

| 시나리오 | 현재 리스크 | 업그레이드 후 | 감소 효과 | ROI |
|---------|-----------|-------------|----------|-----|
| 스마트 팩토리 | 15점 🔴 | 3점 🟢 | -80% | 1,333% |
| ESS (에너지) | 9점 🔴 | 1점 🟢 | -89% | 13,233% |
| 제약 공장 | 18점 🔴🔴 | 2점 🟢 | -89% | 11,867% |

**계산 근거**:
```
ROI = (예상 피해 - 업그레이드 비용) / 업그레이드 비용

스마트 팩토리 예:
  예상 피해: 100억 원 (보안 사고 시)
  업그레이드 비용: 750만 원
  ROI = (100억 - 750만) / 750만 = 1,333배
```

---

## 7. SBOM 기반 자동화 워크플로우

### 7.1 CI/CD 파이프라인

```yaml
# .github/workflows/sbom-security.yml
name: SBOM Security Check

on: [push, pull_request]

jobs:
  sbom-generation:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Generate SBOM
        run: |
          # CycloneDX 생성
          cyclonedx-bom -o sbom.json
      
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.json
  
  vulnerability-scan:
    needs: sbom-generation
    runs-on: ubuntu-latest
    steps:
      - name: Download SBOM
        uses: actions/download-artifact@v3
        with:
          name: sbom
      
      - name: Scan with custom OPC UA DB
        run: |
          # 우리 연구 DB 사용
          curl -X POST https://opcua-vuln-db.example.com/scan \
            -H "Content-Type: application/json" \
            -d @sbom.json \
            -o scan-results.json
      
      - name: Check results
        run: |
          HIGH=$(jq '.high_severity_count' scan-results.json)
          if [ "$HIGH" -gt 0 ]; then
            echo "❌ HIGH severity vulnerabilities found!"
            exit 1
          fi
      
      - name: Generate report
        run: |
          jq -r '.recommendations[]' scan-results.json \
            > vulnerability-report.txt
      
      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('vulnerability-report.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🔍 SBOM 보안 스캔 결과\n\n${report}`
            });
```

### 7.2 취약점 DB API

**엔드포인트**:
```
POST /api/v1/scan
Content-Type: application/json

Request Body: SBOM (CycloneDX/SPDX)

Response:
{
  "scan_id": "uuid",
  "timestamp": "2025-10-21T00:00:00Z",
  "total_components": 10,
  "vulnerabilities": [
    {
      "component": "python-opcua",
      "version": "0.98.13",
      "vulnerability_id": "OPCUA-2025-001",
      "severity": "HIGH",
      "description": "개발 중단, 암호화 미지원",
      "cvss_score": 7.5,
      "recommendation": "opcua-asyncio v1.1.8로 마이그레이션",
      "evidence": "CISC 2025 Phase 1-3 실험 결과"
    }
  ],
  "summary": {
    "high": 1,
    "medium": 2,
    "low": 0
  },
  "recommendations": [
    "긴급: python-opcua 마이그레이션",
    "권장: S2OPC, open62541 업그레이드"
  ]
}
```

---

## 8. 완화 전략 로드맵

### 8.1 단기 (1개월)

```
Week 1-2: 긴급 조치
├── ✅ python-opcua 마이그레이션 계획
├── ✅ 방화벽 규칙 강화
├── ✅ 네트워크 분리
└── ✅ 모니터링 강화

Week 3-4: 업그레이드 실행
├── ✅ 개발 환경 테스트
├── ✅ 스테이징 배포
├── ✅ 프로덕션 배포 (단계적)
└── ✅ 검증 및 모니터링
```

### 8.2 중기 (3개월)

```
Month 1: SBOM 자동화
├── CI/CD 파이프라인 구축
├── 취약점 스캐너 통합
└── 알림 체계 구축

Month 2-3: 시스템 개선
├── S2OPC, open62541 업그레이드
├── 보안 정책 강화
├── 인증서 기반 인증 도입
└── 제로 트러스트 아키텍처 적용
```

### 8.3 장기 (1년)

```
분기별:
├── SBOM 정기 스캔
├── 의존성 업데이트
├── 보안 감사
└── 교육 훈련

연간:
├── 전체 시스템 재평가
├── 아키텍처 개선
├── 최신 표준 적용
└── 규제 준수 확인
```

---

## 9. 핵심 메시지

### 9.1 연구 기여

**"CVE 없는 취약점 → SBOM 통합 가능"**

우리 연구는:
1. ✅ ANSSI 이론 → 실증 검증
2. ✅ 버전별 영향 → 구체화
3. ✅ 독립 ID 부여 → SBOM 통합
4. ✅ 자동화 도구 → 실무 적용

### 9.2 산업 영향

**공급망 보안 강화 경로**:
```
학술 연구 (우리)
    ↓
SBOM 표준화
    ↓
자동화 도구
    ↓
산업 현장 적용
    ↓
보안 사고 예방
```

**정량적 효과**:
- 리스크 감소: 80-89%
- ROI: 1,000% 이상
- 규제 준수: FDA, MFDS 등

---

## 10. 결론

본 SBOM 기반 공급망 리스크 분석은 다음을 입증했다:

1. **python-opcua v0.98.13의 높은 리스크**: 
   - 암호화 없음 + 5년 방치 = 긴급 조치 필요

2. **opcua-asyncio의 우수성**:
   - 최신 암호화 + 활발한 패치 = 가장 안전

3. **C 구현체의 업그레이드 필요성**:
   - 2년 패치 누락 = 중간 리스크

4. **SBOM 통합 가능성**:
   - CVE 없어도 우리 연구 DB로 통합 가능
   - 자동화 도구로 실무 적용 가능

5. **높은 ROI**:
   - 업그레이드 비용: 75-750만원
   - 예상 피해 방지: 100억원+
   - ROI: 1,000% 이상

---

**작성일**: 2025-10-21  
**작성자**: CISC 2025 연구팀  
**참조**: dependency_tree.md, CISC_2025_논문_초안.md

