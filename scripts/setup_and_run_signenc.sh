#!/bin/bash
# ANSSI 시나리오 재현 - 인증서 설정 + SignAndEncrypt 자동 실행

set -e

BASE_DIR="/root/opcua-research"
CERTS_DIR="${BASE_DIR}/certs"
CERTS_NEW_DIR="${BASE_DIR}/certs_new"

echo "=========================================="
echo "ANSSI 시나리오 재현 - 인증서 설정"
echo "=========================================="
echo ""

# 1. 인증서 디렉토리 생성
echo "[1/6] 인증서 디렉토리 생성..."
mkdir -p "$CERTS_NEW_DIR"
cd "$CERTS_NEW_DIR"

# 2. CA 인증서 생성
echo "[2/6] CA 인증서 생성..."
openssl genrsa -out ca.key.pem 4096 2>/dev/null
openssl req -x509 -new -nodes -key ca.key.pem -sha256 -days 3650 \
  -subj "/C=US/ST=Test/L=Test/O=TestLab/OU=CA/CN=TestLab CA" \
  -out ca.cert.pem 2>/dev/null

# 3. 서버 인증서 생성
echo "[3/6] 서버 인증서 생성..."
openssl genrsa -out server.key.pem 2048 2>/dev/null
openssl req -new -key server.key.pem \
  -subj "/C=US/ST=Test/L=Test/O=TestLab/OU=Server/CN=localhost" \
  -out server.csr.pem 2>/dev/null
openssl x509 -req -in server.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial \
  -out server.cert.pem -days 365 -sha256 2>/dev/null

# 4. 클라이언트 인증서 생성
echo "[4/6] 클라이언트 인증서 생성..."
openssl genrsa -out client.key.pem 2048 2>/dev/null
openssl req -new -key client.key.pem \
  -subj "/C=US/ST=Test/L=Test/O=TestLab/OU=Client/CN=client" \
  -out client.csr.pem 2>/dev/null
openssl x509 -req -in client.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial \
  -out client.cert.pem -days 365 -sha256 2>/dev/null

echo "✅ 인증서 생성 완료"
ls -lh *.pem

cd "$BASE_DIR"

# 5. 서버 시작
echo ""
echo "[5/6] 서버 시작 (기존 서버 종료)..."
pkill -f "python.*opcua" || true
sleep 1

# 인증서 경로를 환경변수로 설정
export OPCUA_SERVER_CERT="${CERTS_NEW_DIR}/server.cert.pem"
export OPCUA_SERVER_KEY="${CERTS_NEW_DIR}/server.key.pem"
export OPCUA_CA_CERT="${CERTS_NEW_DIR}/ca.cert.pem"

# NoSecurity 서버로 시작 (인증서 없이)
source venv/bin/activate
python3 servers/python/opcua_server_secure_simple.py > logs/server_anssi.log 2>&1 &
SERVER_PID=$!
echo "서버 PID: $SERVER_PID"
sleep 2

# 서버 상태 확인
if ss -tunlp | grep 4840 > /dev/null; then
    echo "✅ 서버 시작 성공"
else
    echo "❌ 서버 시작 실패"
    tail -20 logs/server_anssi.log
    exit 1
fi

# 6. 테스트 연결
echo ""
echo "[6/6] 클라이언트 연결 테스트..."
python3 clients/python_client_username.py

echo ""
echo "=========================================="
echo "설정 완료"
echo "=========================================="
echo ""
echo "인증서 위치: $CERTS_NEW_DIR"
echo "서버 PID: $SERVER_PID"
echo ""
echo "다음 단계: SignAndEncrypt 강제 연결 테스트"
