#!/bin/bash
# open62541 C 구현체 빌드 스크립트

set -e

ROOT_DIR="/root/opcua-research"
cd "$ROOT_DIR"

echo "=========================================="
echo "open62541 빌드 시작"
echo "=========================================="

# open62541 디렉토리 확인
if [ -d "open62541" ]; then
    echo "기존 open62541 디렉토리 제거..."
    rm -rf open62541
fi

echo "[1/4] open62541 다운로드..."
git clone --depth 1 --branch 1.3.7 https://github.com/open62541/open62541.git
cd open62541

echo "[2/4] 빌드 준비..."
mkdir -p build
cd build

echo "[3/4] CMake 설정..."
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DUA_ENABLE_AMALGAMATION=ON \
    -DUA_BUILD_EXAMPLES=ON

echo "[4/4] 컴파일..."
make -j4

echo ""
echo "=========================================="
echo "빌드 완료"
echo "=========================================="
echo "바이너리 위치:"
ls -lh bin/examples/* || echo "바이너리 없음"
ls -lh lib/* || echo "라이브러리 없음"

echo ""
echo "open62541 빌드 성공!"
