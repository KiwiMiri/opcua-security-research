#!/usr/bin/env bash
# 특정 프레임의 헥스 덤프 및 평문 검색

if [ $# -lt 2 ]; then
    echo "사용법: $0 <PCAP파일> <프레임번호>"
    echo "예: $0 pcaps/python_attack.pcap 14"
    exit 1
fi

PCAP=$1
FRAME=$2

echo "========================================"
echo "프레임 $FRAME 분석"
echo "파일: $PCAP"
echo "========================================"

# 헥스 덤프 저장
TMPFILE="/tmp/frame${FRAME}_hexdump.txt"
tshark -r "$PCAP" -x -Y "frame.number == $FRAME" > "$TMPFILE"

echo ""
echo "[1] 헥스 덤프:"
cat "$TMPFILE"

echo ""
echo "[2] 평문 키워드 검색:"
nl -ba "$TMPFILE" | grep -iE "testuser|password|username|UserNameIdentityToken|SecurityPolicy#None" -C 3 || \
    echo "  (평문 키워드 없음)"

echo ""
echo "[3] ASCII 문자열 추출:"
strings "$PCAP" | grep -iE "password|user|test" | head -10 || echo "  (문자열 없음)"

echo ""
echo "[4] 오프셋 확인:"
echo "위 헥스 덤프에서 왼쪽의 16진수(예: 000e0)가 오프셋입니다."
echo "→ 0x00E0 형태로 논문에 표기"
