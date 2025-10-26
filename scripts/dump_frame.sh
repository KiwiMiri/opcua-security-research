#!/bin/bash
# 특정 프레임의 상세 헥스덤프 추출

if [ $# -lt 2 ]; then
    echo "사용법: $0 <구현체명> <프레임번호>"
    echo "예: $0 node 13"
    exit 1
fi

impl=$1
frame_num=$2

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"
TEMP_DIR="/tmp"

attack_file="${PCAP_DIR}/${impl}_attack.pcap"
normal_file="${PCAP_DIR}/${impl}_normal.pcap"

if [ ! -f "$attack_file" ]; then
    echo "파일을 찾을 수 없습니다: $attack_file"
    exit 1
fi

echo "============================================"
echo "프레임 $frame_num 상세 덤프 ($impl)"
echo "============================================"
echo ""

# TCP 스트림 번호 찾기
stream=$(tshark -r "$attack_file" -Y "frame.number == $frame_num" -T fields -e tcp.stream 2>/dev/null | head -n1)

echo "[1] 헥스 덤프"
echo "--------------------------------------------"
tshark -r "$attack_file" -x -Y "frame.number == $frame_num" 2>/dev/null || echo "프레임을 찾을 수 없습니다"
echo ""

echo "[2] 자격증명 키워드 검색"
echo "--------------------------------------------"
tshark -r "$attack_file" -x -Y "frame.number == $frame_num" 2>/dev/null | \
    nl -ba | grep -iE "testuser|password|UserNameIdentityToken|usernamePassword|SecurityPolicy#None" -C 3 || \
    echo "키워드를 찾을 수 없습니다"
echo ""

if [ ! -z "$stream" ]; then
    echo "[3] TCP 스트림 전체 ($stream)"
    echo "--------------------------------------------"
    tshark -r "$attack_file" -q -z follow,tcp,raw,$stream 2>/dev/null | \
        grep -iE "SecurityPolicy#None|UserNameIdentityToken|usernamePassword|password|testuser" -C 2 || \
        echo "스트림 데이터 없음"
fi

echo ""
echo "============================================"
echo "덤프 완료"
echo "============================================"
echo ""
echo "오프셋 추출:"
echo "  위 헥스 덤프에서 왼쪽의 16진수(예: 000e0)가 오프셋입니다"
echo ""
echo "논문용 캡션 생성:"
echo "  ./scripts/generate_caption.sh $impl $frame_num <오프셋>"
