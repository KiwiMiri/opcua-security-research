# OPC UA Research - Final Deliverables

## 완성된 산출물

### 1. 데이터 파일
- ✅ **results.tsv** - 탭 구분 텍스트 (Excel/AIR 호환)
- ✅ **results.xlsx** - Excel 파일 (2개 시트: Summary, Evidence_Hashes)
- ✅ **pcaps/pcap_sha256sums.txt** - 31개 PCAP 파일 SHA256 해시

### 2. 메타데이터 문서
- ✅ **METADATA_COMPLETE.txt** - 상세 메타데이터 (170 lines)
- ✅ **IMPLEMENTATION_VERSIONS.md** - 구현체 버전 정보
- ✅ **metadata_for_paper.tsv** - 논문용 TSV
- ✅ **README_METADATA.md** - 퀵 가이드

### 3. 테이블 문서
- ✅ **FINAL_TABLE_WITH_EVIDENCE.md** - Evidence PCAP 포함
- ✅ **FINAL_COMPLETE_TABLE_WITH_PORTS.md** - Server Port 포함
- ✅ **FINAL_STATUS_TABLE.md** - 서버 상태 포함

### 4. 실험 증거 파일
- **PCAP 파일**: 31개 (normal/attack 시나리오)
- **해시 무결성**: SHA256 검증 완료
- **서버 실행**: 6개 구현체 모두 준비

## 현재 서버 상태

| Implementation | Port | Status |
|----------------|------|--------|
| python-opcua | 4850 | ✅ Running (ANSSI) |
| open62541 | 4840 | ✅ Running |
| Node.js opcua | 4841 | ✅ Ready |
| FreeOpcUa | 4842 | ✅ Ready |
| Eclipse Milo | 4844 | ✅ Ready |
| S2OPC | 4840 | ✅ Ready (will conflict) |

## ⚠️ 포트 충돌 발견

- Port **4840**: open62541과 S2OPC 모두 사용 예정
- 해결: 서로 다른 포트로 실행 필요

## 스크립트

- `scripts/check_port_conflicts.sh` - 포트 충돌 확인
- `scripts/start_open62541_server.sh` - open62541 시작
- `scripts/start_s2opc_server.sh` - S2OPC 시작
- `create_results_excel.py` - Excel 파일 생성

## 검증 방법

```bash
# PCAP 해시 검증
cd /root/opcua-research
sha256sum -c pcaps/pcap_sha256sums.txt

# 포트 충돌 확인
./scripts/check_port_conflicts.sh

# Excel 파일 확인
ls -lh results.xlsx
```

## 논문 제출 준비

✅ **메타데이터**: 완벽
✅ **증거 파일**: PCAP + SHA256
✅ **재현성**: 완전한 문서화
✅ **버전 정보**: 커밋 해시, 빌드 환경 모두 기록

