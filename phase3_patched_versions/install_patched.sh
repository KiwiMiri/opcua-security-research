#!/bin/bash
# Phase 3 Step 2: 패치 버전 설치 스크립트

set -euo pipefail

BASE_DIR="/root/opcua-research"
PHASE3_DIR="${BASE_DIR}/phase3_patched_versions"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║      Phase 3 Step 2: 패치 버전 설치                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

cd "${BASE_DIR}"

# 1. open62541 v1.4.14 설치
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/3] open62541 v1.4.14 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "open62541-1.4.14" ]; then
    echo "📦 다운로드 중..."
    wget -q --show-progress https://github.com/open62541/open62541/archive/refs/tags/v1.4.14.tar.gz
    tar -xzf v1.4.14.tar.gz
    rm v1.4.14.tar.gz
    
    echo "📦 UA Nodeset 다운로드..."
    cd open62541-1.4.14/deps/ua-nodeset
    wget -q https://github.com/OPCFoundation/UA-Nodeset/archive/refs/heads/v1.04.tar.gz -O ua-nodeset.tar.gz
    tar -xzf ua-nodeset.tar.gz --strip-components=1
    rm ua-nodeset.tar.gz
    cd ../..
    
    echo "🔨 빌드 시작..."
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DUA_ENABLE_ENCRYPTION=ON \
             -DUA_BUILD_EXAMPLES=ON \
             -DUA_NAMESPACE_ZERO=FULL
    make -j$(nproc)
    cd "${BASE_DIR}"
    
    echo "✅ open62541 v1.4.14 설치 완료"
else
    echo "⚠️  open62541-1.4.14 이미 존재 (건너뜀)"
fi
echo ""

# 2. S2OPC v1.6.0 설치
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/3] S2OPC v1.6.0 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "S2OPC-1.6.0" ]; then
    echo "📦 다운로드 중..."
    wget -q --show-progress https://github.com/systerel/S2OPC/archive/refs/tags/S2OPC_Toolkit_1.6.0.tar.gz
    tar -xzf S2OPC_Toolkit_1.6.0.tar.gz
    rm S2OPC_Toolkit_1.6.0.tar.gz
    
    # 디렉토리명 정리
    if [ -d "S2OPC-S2OPC_Toolkit_1.6.0" ]; then
        mv S2OPC-S2OPC_Toolkit_1.6.0 S2OPC-1.6.0
    fi
    
    echo "🔨 빌드 시작..."
    cd S2OPC-1.6.0
    mkdir -p build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DS2OPC_CLIENTSERVER_ONLY=ON \
             -DBUILD_SHARED_LIBS=OFF \
             -DENABLE_TESTING=OFF
    make -j$(nproc)
    cd "${BASE_DIR}"
    
    echo "✅ S2OPC v1.6.0 설치 완료"
else
    echo "⚠️  S2OPC-1.6.0 이미 존재 (건너뜀)"
fi
echo ""

# 3. Python asyncua 설치 (python-opcua 후속)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/3] Python asyncua (최신) 설치"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -d "python-opcua-latest" ]; then
    echo "🐍 가상환경 생성..."
    python3 -m venv python-opcua-latest
    
    echo "📦 asyncua 설치..."
    ./python-opcua-latest/bin/pip install --upgrade pip
    ./python-opcua-latest/bin/pip install asyncua
    
    echo "✅ Python asyncua 설치 완료"
else
    echo "⚠️  python-opcua-latest 이미 존재 (건너뜀)"
fi
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                설치 완료!                                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ 설치된 패치 버전:"
echo "   • open62541 v1.4.14"
echo "   • S2OPC v1.6.0"
echo "   • Python asyncua (최신)"
echo ""
echo "📁 위치:"
echo "   • ${BASE_DIR}/open62541-1.4.14/"
echo "   • ${BASE_DIR}/S2OPC-1.6.0/"
echo "   • ${BASE_DIR}/python-opcua-latest/"
echo ""
echo "🎯 다음: Phase 3 Step 3 - 비교 테스트"
echo ""

