#!/bin/bash

# OPC UA 실험 환경 자동화 설정 스크립트
# 컨테이너 또는 VM에서 root 권한으로 실행

set -e  # 오류 발생시 스크립트 중단

echo "=== OPC UA 실험 환경 설정 시작 ==="

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 디렉토리 구조 생성
log_info "실험 디렉토리 구조 생성 중..."
mkdir -p /root/opcua-research/{servers,clients,monitoring,certs,results,logs,scripts}
mkdir -p /root/opcua-research/results/{pcap,mitm,analysis}
mkdir -p /root/opcua-research/servers/{python,nodejs,open62541,s2opc}
mkdir -p /root/opcua-research/clients/{python,nodejs}

# 시스템 패키지 업데이트 및 설치
log_info "시스템 패키지 업데이트 중..."
apt-get update -y

log_info "필수 시스템 패키지 설치 중..."
apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    vim \
    htop \
    net-tools \
    tcpdump \
    wireshark-common \
    tshark \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    nodejs \
    npm \
    openssl \
    libssl-dev \
    pkg-config \
    libxml2-dev \
    libffi-dev \
    libc6-dev

# Python 가상환경 설정
log_info "Python 가상환경 설정 중..."
cd /root/opcua-research
python3 -m venv venv
source venv/bin/activate

# Python OPC UA 패키지 설치
log_info "Python OPC UA 패키지 설치 중..."
pip install --upgrade pip
pip install \
    opcua \
    cryptography \
    lxml \
    requests \
    asyncio-mqtt \
    paho-mqtt

# Node.js OPC UA 패키지 설치
log_info "Node.js OPC UA 패키지 설치 중..."
npm install -g node-opcua

# open62541 빌드 (선택사항)
log_info "open62541 소스 다운로드 및 빌드 중..."
cd /root/opcua-research
if [ ! -d "open62541" ]; then
    git clone https://github.com/open62541/open62541.git
fi

cd open62541
git checkout master
git pull

# open62541 빌드
mkdir -p build
cd build
cmake -DUA_ENABLE_AMALGAMATION=ON -DUA_ENABLE_ENCRYPTION=ON ..
make -j$(nproc)

# 설치 (선택사항)
# make install

log_success "open62541 빌드 완료"

# S2OPC 다운로드 (선택사항)
log_info "S2OPC 다운로드 중..."
cd /root/opcua-research
if [ ! -d "s2opc" ]; then
    git clone https://github.com/commissariat-a-lenergie-atomique-et-aux-energies-alternatives/s2opc.git
fi

# 테스트용 인증서 생성
log_info "테스트용 인증서 생성 중..."
cd /root/opcua-research/certs

# CA 인증서 생성
openssl req -x509 -newkey rsa:2048 -keyout ca-key.pem -out ca-cert.pem -days 365 -nodes \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=OPCUA-Test/OU=Research/CN=Test-CA"

# 서버 인증서 생성
openssl req -newkey rsa:2048 -keyout server-key.pem -out server-csr.pem -nodes \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=OPCUA-Test/OU=Research/CN=OPCUA-Server"

openssl x509 -req -in server-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -out server-cert.pem -days 365 -CAcreateserial

# 클라이언트 인증서 생성
openssl req -newkey rsa:2048 -keyout client-key.pem -out client-csr.pem -nodes \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=OPCUA-Test/OU=Research/CN=OPCUA-Client"

openssl x509 -req -in client-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -out client-cert.pem -days 365 -CAcreateserial

# 권한 설정
chmod 600 *.pem
chmod 644 *.csr

log_success "인증서 생성 완료"

# 서버 스크립트 생성
log_info "서버 시작 스크립트 생성 중..."

# Python OPC UA 서버 스크립트
cat > /root/opcua-research/scripts/start_python_server.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research
source venv/bin/activate

echo "Python OPC UA 서버 시작 중..."
python3 servers/python/opcua_server.py > logs/python_server.log 2>&1 &
echo $! > server_pids.txt
echo "Python 서버 PID: $!"
EOF

# Node.js OPC UA 서버 스크립트
cat > /root/opcua-research/scripts/start_nodejs_server.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "Node.js OPC UA 서버 시작 중..."
node servers/nodejs/opcua_server.js > logs/nodejs_server.log 2>&1 &
echo $! >> server_pids.txt
echo "Node.js 서버 PID: $!"
EOF

# open62541 서버 스크립트
cat > /root/opcua-research/scripts/start_open62541_server.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "open62541 OPC UA 서버 시작 중..."
./open62541/build/bin/examples_server > logs/open62541_server.log 2>&1 &
echo $! >> server_pids.txt
echo "open62541 서버 PID: $!"
EOF

# 모니터링 스크립트 생성
log_info "모니터링 스크립트 생성 중..."

# 패킷 캡처 스크립트
cat > /root/opcua-research/scripts/start_packet_capture.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "패킷 캡처 시작 중..."
# OPC UA 기본 포트 4840 캡처
tcpdump -i any -w results/pcap/opcua_capture_$(date +%Y%m%d_%H%M%S).pcap port 4840 &
echo $! > monitoring_pids.txt
echo "패킷 캡처 PID: $!"
EOF

# MITM 프록시 스크립트 (mitmproxy 설치 필요)
cat > /root/opcua-research/scripts/start_mitm_proxy.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "MITM 프록시 시작 중..."
# mitmproxy 설치가 필요한 경우
# pip install mitmproxy
# mitmdump -s monitoring/mitm_script.py --listen-port 8080 > logs/mitm.log 2>&1 &
echo "MITM 프록시 설정 완료 (mitmproxy 설치 필요)"
EOF

# 모든 서버 시작 스크립트
cat > /root/opcua-research/scripts/start_all_servers.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "=== 모든 OPC UA 서버 시작 ==="
./scripts/start_python_server.sh
sleep 2
./scripts/start_nodejs_server.sh
sleep 2
./scripts/start_open62541_server.sh

echo "모든 서버가 시작되었습니다."
echo "PID 파일: server_pids.txt"
EOF

# 모든 서버 중지 스크립트
cat > /root/opcua-research/scripts/stop_all_servers.sh << 'EOF'
#!/bin/bash
cd /root/opcua-research

echo "=== 모든 OPC UA 서버 중지 ==="
if [ -f server_pids.txt ]; then
    while read pid; do
        if [ ! -z "$pid" ]; then
            echo "프로세스 $pid 종료 중..."
            kill $pid 2>/dev/null || true
        fi
    done < server_pids.txt
    rm -f server_pids.txt
fi

# 추가 프로세스 정리
pkill -f "opcua_server.py" 2>/dev/null || true
pkill -f "opcua_server.js" 2>/dev/null || true
pkill -f "examples_server" 2>/dev/null || true

echo "모든 서버가 중지되었습니다."
EOF

# 스크립트 실행 권한 부여
chmod +x /root/opcua-research/scripts/*.sh

# 기본 Python OPC UA 서버 코드 생성
log_info "기본 Python OPC UA 서버 코드 생성 중..."
mkdir -p /root/opcua-research/servers/python

cat > /root/opcua-research/servers/python/opcua_server.py << 'EOF'
#!/usr/bin/env python3
"""
기본 OPC UA 서버 구현
"""

import asyncio
import logging
from opcua import Server, ua
from opcua.server.users import User

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OPCUAServer:
    def __init__(self, endpoint="opc.tcp://0.0.0.0:4840/freeopcua/server/"):
        self.server = Server()
        self.server.set_endpoint(endpoint)
        self.server.set_server_name("OPC UA Research Server")
        
        # 네임스페이스 설정
        self.ns = self.server.register_namespace("http://opcua-research.org")
        
        # 보안 설정 (테스트용)
        self.server.set_security_policy([
            ua.SecurityPolicyType.NoSecurity,
            ua.SecurityPolicyType.Basic128Rsa15,
            ua.SecurityPolicyType.Basic256
        ])
        
    def setup_nodes(self):
        """노드 구조 설정"""
        # 루트 노드
        root = self.server.get_root_node()
        objects = self.server.get_objects_node()
        
        # 디바이스 노드 생성
        device = objects.add_object(self.ns, "ResearchDevice")
        device.set_writable()
        
        # 변수 노드들 추가
        temp_var = device.add_variable(self.ns, "Temperature", 25.0)
        temp_var.set_writable()
        
        pressure_var = device.add_variable(self.ns, "Pressure", 1013.25)
        pressure_var.set_writable()
        
        status_var = device.add_variable(self.ns, "Status", "Running")
        status_var.set_writable()
        
        logger.info("노드 구조 설정 완료")
        
    def start(self):
        """서버 시작"""
        try:
            self.setup_nodes()
            self.server.start()
            logger.info(f"OPC UA 서버가 시작되었습니다: {self.server.endpoint}")
            return True
        except Exception as e:
            logger.error(f"서버 시작 실패: {e}")
            return False

def main():
    server = OPCUAServer()
    if server.start():
        try:
            # 서버 실행 유지
            while True:
                import time
                time.sleep(1)
        except KeyboardInterrupt:
            logger.info("서버 종료 중...")
            server.server.stop()

if __name__ == "__main__":
    main()
EOF

# 기본 Node.js OPC UA 서버 코드 생성
log_info "기본 Node.js OPC UA 서버 코드 생성 중..."
mkdir -p /root/opcua-research/servers/nodejs

cat > /root/opcua-research/servers/nodejs/opcua_server.js << 'EOF'
const { OPCUAServer } = require("node-opcua");

const server = new OPCUAServer({
    port: 4840,
    resourcePath: "/UA/ResearchServer",
    buildInfo: {
        productName: "OPC UA Research Server",
        buildNumber: "1.0.0"
    }
});

// 네임스페이스 등록
const namespace = server.engine.addressSpace.getOwnNamespace();

// 디바이스 객체 생성
const device = namespace.addObject({
    browseName: "ResearchDevice",
    nodeId: "s=ResearchDevice"
});

// 변수 노드들 추가
const temperature = namespace.addVariable({
    componentOf: device,
    browseName: "Temperature",
    nodeId: "s=Temperature",
    dataType: "Double",
    value: { dataType: "Double", value: 25.0 }
});

const pressure = namespace.addVariable({
    componentOf: device,
    browseName: "Pressure", 
    nodeId: "s=Pressure",
    dataType: "Double",
    value: { dataType: "Double", value: 1013.25 }
});

const status = namespace.addVariable({
    componentOf: device,
    browseName: "Status",
    nodeId: "s=Status", 
    dataType: "String",
    value: { dataType: "String", value: "Running" }
});

// 서버 시작
server.start(() => {
    console.log("OPC UA 서버가 시작되었습니다.");
    console.log(`엔드포인트: ${server.getEndpointUrl()}`);
    
    // 주기적으로 값 업데이트 (시뮬레이션)
    setInterval(() => {
        const now = new Date();
        temperature.setValueFromSource({
            dataType: "Double",
            value: 20 + Math.sin(now.getTime() / 10000) * 10
        });
        
        pressure.setValueFromSource({
            dataType: "Double", 
            value: 1000 + Math.sin(now.getTime() / 15000) * 50
        });
    }, 1000);
});

// 정리 함수
process.on('SIGINT', () => {
    console.log("서버 종료 중...");
    server.shutdown(() => {
        process.exit(0);
    });
});
EOF

# 환경 설정 완료 메시지
log_success "=== OPC UA 실험 환경 설정 완료 ==="
echo ""
echo "설정된 구성요소:"
echo "  - Python 가상환경: /root/opcua-research/venv"
echo "  - Node.js OPC UA: 전역 설치됨"
echo "  - open62541: /root/opcua-research/open62541/build"
echo "  - 인증서: /root/opcua-research/certs/"
echo "  - 서버 스크립트: /root/opcua-research/scripts/"
echo "  - 결과 저장: /root/opcua-research/results/"
echo ""
echo "사용 가능한 명령어:"
echo "  ./scripts/start_all_servers.sh    # 모든 서버 시작"
echo "  ./scripts/stop_all_servers.sh     # 모든 서버 중지"
echo "  ./scripts/start_packet_capture.sh # 패킷 캡처 시작"
echo ""
echo "서버 엔드포인트:"
echo "  Python: opc.tcp://localhost:4840/freeopcua/server/"
echo "  Node.js: opc.tcp://localhost:4840/UA/ResearchServer"
echo "  open62541: opc.tcp://localhost:4840/"
