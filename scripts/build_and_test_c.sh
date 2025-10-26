#!/bin/bash
# open62541 C 구현체 빌드 및 테스트

set -e

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "open62541 C 구현체 빌드 및 테스트"
echo "=========================================="

# 필요한 패키지 설치
echo "[1/5] 필요한 패키지 설치 확인..."
apt-get update -qq
apt-get install -y -qq cmake build-essential git

# open62541 디렉토리 확인
if [ -d "open62541" ]; then
    echo "기존 open62541 디렉토리 사용..."
else
    echo "[2/5] open62541 다운로드..."
    git clone --depth 1 --branch 1.3.7 https://github.com/open62541/open62541.git
fi

cd open62541

echo "[3/5] 빌드 준비..."
mkdir -p build
cd build

echo "[4/5] CMake 설정..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DUA_ENABLE_AMALGAMATION=ON \
    -DUA_BUILD_EXAMPLES=ON \
    -DUA_LOGLEVEL=200

echo "[5/5] 컴파일..."
make -j4

echo ""
echo "=========================================="
echo "빌드 완료"
echo "=========================================="

# 서버 예제 찾기
if [ -f "bin/server_ctt" ]; then
    echo "서버 예제: bin/server_ctt"
    SERVER=bin/server_ctt
elif [ -f "bin/examples/server" ]; then
    echo "서버 예제: bin/examples/server"
    SERVER=bin/examples/server
else
    echo "서버 예제를 찾을 수 없습니다."
    ls -la bin/
    exit 1
fi

echo ""
echo "open62541 빌드 성공!"
echo "서버 실행: $SERVER"
