# opcua-asyncio: python-opcua의 후속 프로젝트

## 📊 프로젝트 개요

### 기본 정보
- **프로젝트명:** opcua-asyncio
- **GitHub:** https://github.com/FreeOpcUa/opcua-asyncio
- **라이선스:** LGPL v3.0
- **언어:** Python
- **최신 버전:** v1.1.8 (2025-09-05)
- **Stars:** 1,329 ⭐
- **Forks:** 413
- **상태:** ✅ 활발히 개발 중

### 설명
> OPC UA library for python >= 3.7

---

## 🔄 python-opcua와의 관계

### 프로젝트 전환

```
2015-2020: python-opcua
├── 동기식 (synchronous) API
├── Python 2/3 지원
├── 마지막 릴리스: v0.98.13
└── 개발 중단 ⚠️

         ↓ 포크 & 재작성

2020-현재: opcua-asyncio
├── 비동기식 (asynchronous) API
├── Python 3.7+ 전용
├── 현재 릴리스: v1.1.8
└── 활발한 개발 중 ✅
```

### 주요 차이점

| 항목 | python-opcua | opcua-asyncio |
|------|--------------|---------------|
| **API 스타일** | 동기식 (sync) | 비동기식 (async/await) |
| **Python 버전** | 2.7, 3.x | 3.7+ |
| **개발 상태** | ❌ 중단 (2020) | ✅ 활발 (2025) |
| **마지막 버전** | v0.98.13 | v1.1.8 |
| **보안 패치** | ❌ 없음 | ✅ 지속 제공 |
| **성능** | 보통 | 향상됨 (asyncio) |
| **패키지명** | `opcua` | `asyncua` |

---

## 💻 설치 및 사용법

### 설치

```bash
# pip로 설치
pip install asyncua

# 또는 최신 개발 버전
pip install git+https://github.com/FreeOpcUa/opcua-asyncio.git
```

### 코드 비교

#### python-opcua (동기식)

```python
from opcua import Client

# 클라이언트 생성
client = Client("opc.tcp://localhost:4840")

# 연결
client.connect()

# 노드 읽기
node = client.get_node("ns=2;i=2")
value = node.get_value()

# 연결 종료
client.disconnect()
```

#### opcua-asyncio (비동기식)

```python
import asyncio
from asyncua import Client

async def main():
    # 클라이언트 생성
    client = Client("opc.tcp://localhost:4840")
    
    # 연결
    async with client:
        # 노드 읽기
        node = client.get_node("ns=2;i=2")
        value = await node.read_value()
        print(value)

# 실행
asyncio.run(main())
```

### 서버 예제

#### python-opcua (동기식)

```python
from opcua import Server

server = Server()
server.set_endpoint("opc.tcp://0.0.0.0:4840")

# 서버 시작
server.start()

try:
    while True:
        time.sleep(1)
finally:
    server.stop()
```

#### opcua-asyncio (비동기식)

```python
import asyncio
from asyncua import Server

async def main():
    server = Server()
    await server.init()
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # 서버 시작
    async with server:
        while True:
            await asyncio.sleep(1)

asyncio.run(main())
```

---

## 🎯 Phase 3에 opcua-asyncio 통합하기

### Option A: 단순 테스트만 추가

**장점:**
- ✅ 최신 Python OPC UA 라이브러리 테스트
- ✅ 보안 개선 확인 가능

**단점:**
- ⚠️ python-opcua와 직접 비교 불가 (API 다름)
- ⚠️ 별도의 서버 코드 필요

**구현:**
```bash
# 포트 5843에 opcua-asyncio 서버 추가
포트 4841: python-opcua v0.98.13 (레거시)
포트 5843: opcua-asyncio v1.1.8 (최신) ✨
```

### Option B: python-opcua 대체

**장점:**
- ✅ 최신 라이브러리로 완전 전환
- ✅ 지속적인 보안 패치 수혜

**단점:**
- ⚠️ 모든 코드 재작성 필요 (async/await)
- ⚠️ 기존 python-opcua 테스트 불가

---

## 🔐 보안 개선 사항

### opcua-asyncio의 보안 기능

1. **최신 보안 패치**
   - 지속적인 업데이트
   - CVE 대응

2. **암호화 지원**
   - cryptography 라이브러리 통합
   - 최신 암호화 알고리즘

3. **인증 강화**
   - 개선된 사용자 인증
   - 토큰 관리

4. **인증서 처리**
   - 자동 인증서 관리
   - 검증 강화

---

## 📋 마이그레이션 가이드

### 1. 패키지 이름 변경

```python
# Before (python-opcua)
from opcua import Client, Server, ua

# After (opcua-asyncio)
from asyncua import Client, Server, ua
```

### 2. async/await 패턴

```python
# Before
def read_value():
    client = Client(url)
    client.connect()
    value = node.get_value()
    client.disconnect()
    return value

# After
async def read_value():
    async with Client(url) as client:
        value = await node.read_value()
        return value
```

### 3. 서버 초기화

```python
# Before
server = Server()
server.start()

# After
server = Server()
await server.init()
async with server:
    # 서버 실행
```

---

## 🧪 Phase 3 통합 제안

### 제안 1: 추가 테스트 (권장)

**구성:**
```
취약 버전 (4840-4842):
├── S2OPC v1.4.0       (4840)
├── python-opcua v0.98.13 (4841)
└── open62541 v1.3.8   (4842)

패치 버전 (5840-5843):
├── S2OPC v1.6.0       (5840)
├── python-opcua v0.98.13 (5841) - 동일
├── open62541 v1.4.14  (5842)
└── opcua-asyncio v1.1.8 (5843) ✨ NEW
```

**비교:**
- S2OPC: v1.4.0 → v1.6.0 ✅
- Python: v0.98.13 → v1.1.8 (asyncio) ⚠️ (다른 프로젝트)
- open62541: v1.3.8 → v1.4.14 ✅

### 제안 2: 참고용 설치만

**구성:**
- opcua-asyncio를 별도로 설치
- 문서에 정보만 기록
- 실제 비교는 하지 않음

---

## 📊 버전 히스토리

### opcua-asyncio 주요 릴리스

| 버전 | 날짜 | 주요 변경사항 |
|------|------|--------------|
| v1.1.8 | 2025-09-05 | 릴리스 스크립트 수정 |
| v1.1.0 | 2024년 | 주요 기능 개선 |
| v1.0.0 | 2023년 | 첫 안정 버전 |
| v0.9.x | 2021-2022 | 베타 버전 |

---

## 🔗 관련 링크

- **GitHub:** https://github.com/FreeOpcUa/opcua-asyncio
- **문서:** https://opcua-asyncio.readthedocs.io/
- **PyPI:** https://pypi.org/project/asyncua/
- **예제:** https://github.com/FreeOpcUa/opcua-asyncio/tree/master/examples

---

## 💡 결론

### opcua-asyncio를 사용해야 하는 이유

1. ✅ **활발한 개발**: 지속적인 업데이트와 버그 수정
2. ✅ **보안 패치**: 최신 보안 이슈 대응
3. ✅ **성능 향상**: asyncio 기반으로 더 나은 성능
4. ✅ **최신 Python**: Python 3.7+ 지원
5. ✅ **커뮤니티**: 활발한 커뮤니티 지원

### python-opcua를 계속 사용하는 경우

1. ⚠️ **보안 위험**: 패치 없음
2. ⚠️ **레거시**: 중단된 프로젝트
3. ⚠️ **호환성**: 구형 코드 유지 목적만

**권장:** 새로운 프로젝트는 opcua-asyncio 사용 ✅

---

**작성일:** 2025-10-21  
**opcua-asyncio 버전:** v1.1.8  
**python-opcua 버전:** v0.98.13 (중단)

