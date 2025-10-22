# OPC UA Security Research Project

## 프로젝트 개요

산업 제어 시스템에서 사용되는 OPC UA 프로토콜의 보안 취약점을 연구하는 프로젝트입니다.

## 프로젝트 구조

### Phase 1: 취약한 버전 서버 구현
- S2OPC v1.4.0
- python-opcua v0.98.13  
- open62541 v1.3.8

### Phase 2: 교차 공격 테스트
- 서로 다른 구현체 간 공격 테스트
- MITM 프록시를 통한 패킷 분석

### Phase 3: 패치 버전 비교
- S2OPC v1.6.0
- opcua-asyncio v1.1.8
- open62541 v1.4.14

## 주요 파일

- `start_servers.sh`: 취약한 버전 서버 시작
- `phase3_patched_versions/start_patched_servers.sh`: 패치 버전 서버 시작
- `exploits/`: 공격 도구 및 분석 스크립트
- `sbom_analysis/`: 공급망 보안 분석

## 연구 목적

이 프로젝트는 교육 및 연구 목적으로만 사용됩니다.

## 라이선스

연구 목적으로만 사용하시기 바랍니다.

