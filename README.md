# OPC UA Security Research Project

## 프로젝트 개요

산업 제어 시스템에서 사용되는 OPC UA 프로토콜의 보안 취약점을 연구하는 프로젝트입니다. 다양한 OPC UA 구현체를 비교 분석하기 위한 종합적인 실험 환경을 제공합니다.

## 🎯 지원하는 OPC UA 구현체

| 구현체 | 언어 | 포트 | 라이브러리 | 특징 |
|--------|------|------|------------|------|
| **Python** | Python | 4840 | `opcua` | 객체지향적 API, 동적 노드 생성 |
| **Node.js** | JavaScript | 4841 | `node-opcua` | 이벤트 기반, 비동기 I/O |
| **open62541** | C | 4842 | open62541 | 네이티브 성능, 메모리 효율성 |
| **FreeOpcUa** | Python | 4843 | `freeopcua` | 경량화된 Python 구현 |
| **Eclipse Milo** | Java | 4844 | Eclipse Milo | 엔터프라이즈급 Java 구현 |
| **S2OPC** | C | 4845 | S2OPC | 산업용 고성능 구현 |

## 🔬 연구 단계

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

## 🚀 빠른 시작

### Docker 사용 (권장)

```bash
# Docker Compose로 모든 서비스 시작
docker-compose up -d

# 서버 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f
```

### 로컬 설치

```bash
# 환경 설정 실행
sudo ./setup_environment.sh

# 모든 서버 시작
./scripts/start_all_servers.sh

# 서버 상태 확인
netstat -tlnp | grep 484
```

## 📁 디렉토리 구조

```
/root/opcua-research/
├── servers/              # 서버 구현체
│   ├── python/          # Python OPC UA 서버
│   ├── nodejs/          # Node.js OPC UA 서버
│   ├── open62541/       # C 라이브러리 서버
│   ├── freeopcua/       # FreeOpcUa 서버
│   ├── eclipse-milo/    # Java 서버
│   └── s2opc/           # S2OPC 서버
├── clients/             # 클라이언트 구현체
├── scripts/             # 실행 스크립트들
├── certs/               # 인증서 파일들
├── results/             # 실험 결과
│   ├── pcap/            # 패킷 캡처 파일
│   ├── mitm/            # MITM 로그
│   └── analysis/        # 분석 결과
├── exploits/            # 공격 도구 및 분석 스크립트
├── sbom_analysis/       # 공급망 보안 분석
└── logs/                # 서버 로그
```

## 🧪 실험 워크플로우

### 1. 환경 설정
```bash
# 모든 서버 시작
./scripts/start_all_servers.sh

# 패킷 캡처 시작
./scripts/start_packet_capture.sh
```

### 2. 성능 테스트
```bash
# 각 서버별 성능 측정
# - 연결 시간
# - 처리량 (TPS)
# - 메모리 사용량
# - CPU 사용률
```

### 3. 보안 테스트
```bash
# 인증서 기반 보안 테스트
# - 암호화 성능
# - 인증 오버헤드
# - 보안 정책 비교
```

### 4. 호환성 테스트
```bash
# 클라이언트-서버 호환성
# - 표준 준수도
# - 프로토콜 호환성
# - 데이터 타입 지원
```

## 🔧 사용 가능한 명령어

### 서버 관리
```bash
# 모든 서버 시작
./scripts/start_all_servers.sh

# 모든 서버 중지
./scripts/stop_all_servers.sh

# 개별 서버 시작
./scripts/start_python_server.sh
./scripts/start_nodejs_server.sh
./scripts/start_open62541_server.sh
./scripts/start_freeopcua_server.sh
./scripts/start_eclipse_milo_server.sh
```

### 모니터링
```bash
# 패킷 캡처 시작
./scripts/start_packet_capture.sh

# 서버 로그 확인
tail -f logs/*.log

# 네트워크 상태 확인
netstat -tlnp | grep 484
```

## 📊 실험 결과 분석

### 성능 메트릭
- **처리량**: 초당 요청 수 (RPS)
- **지연시간**: 평균 응답 시간
- **메모리**: 런타임 메모리 사용량
- **CPU**: CPU 사용률

### 보안 메트릭
- **암호화 오버헤드**: 보안 활성화 시 성능 저하
- **인증 시간**: 클라이언트 인증 소요 시간
- **키 교환**: 보안 세션 설정 시간

### 호환성 메트릭
- **연결 성공률**: 클라이언트 연결 성공 비율
- **데이터 정확성**: 전송 데이터 무결성
- **표준 준수**: OPC UA 표준 준수도

## 🔍 각 구현체별 특징

### Python OPC UA (`opcua`)
- **장점**: 개발 속도 빠름, 유연한 구조
- **단점**: 성능 오버헤드, 메모리 사용량 높음
- **적합한 용도**: 프로토타이핑, 연구용

### Node.js OPC UA (`node-opcua`)
- **장점**: 실시간 처리, 확장성 좋음
- **단점**: 단일 스레드, CPU 집약적 작업 제한
- **적합한 용도**: 웹 기반 시스템, 실시간 모니터링

### open62541 (C)
- **장점**: 최고 성능, 낮은 메모리 사용량
- **단점**: 개발 복잡도 높음, 디버깅 어려움
- **적합한 용도**: 임베디드 시스템, 고성능 요구사항

### FreeOpcUa (Python)
- **장점**: 경량화, 간단한 API
- **단점**: 기능 제한, 커뮤니티 지원 부족
- **적합한 용도**: 간단한 프로젝트, 학습용

### Eclipse Milo (Java)
- **장점**: 엔터프라이즈급, 안정성 높음
- **단점**: 메모리 사용량 높음, JVM 오버헤드
- **적합한 용도**: 대규모 시스템, 엔터프라이즈 환경

### S2OPC (C)
- **장점**: 산업용 고성능, 안정성
- **단점**: 복잡한 설정, 라이선스 제약
- **적합한 용도**: 산업용 시스템, 고신뢰성 요구사항

## 🐳 Docker 사용법

### 컨테이너 빌드
```bash
docker build -t opcua-research .
```

### 컨테이너 실행
```bash
docker run -d -p 4840-4844:4840-4844 --name opcua-research opcua-research
```

### Docker Compose 사용
```bash
# 백그라운드 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down
```

## 📝 로그 및 모니터링

### 서버 로그
- `logs/python_server.log`: Python 서버 로그
- `logs/nodejs_server.log`: Node.js 서버 로그
- `logs/open62541_server.log`: open62541 서버 로그
- `logs/freeopcua_server.log`: FreeOpcUa 서버 로그
- `logs/eclipse_milo_server.log`: Eclipse Milo 서버 로그

### 패킷 캡처
- `results/pcap/`: OPC UA 통신 패킷 캡처 파일
- `results/mitm/`: MITM 프록시 로그
- `results/analysis/`: 분석 결과

## 🛡️ 보안 연구

### 주요 파일
- `start_servers.sh`: 취약한 버전 서버 시작
- `phase3_patched_versions/start_patched_servers.sh`: 패치 버전 서버 시작
- `exploits/`: 공격 도구 및 분석 스크립트
- `sbom_analysis/`: 공급망 보안 분석

### 연구 목적
이 프로젝트는 교육 및 연구 목적으로만 사용됩니다.

## 🤝 기여하기

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 라이선스

연구 목적으로만 사용하시기 바랍니다.

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 생성해 주세요.

