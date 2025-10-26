#!/bin/bash
# 평문 자격증명 검색 스크립트
# 공격 pcap에서 평문 인증 정보 찾기

if [ $# -lt 2 ]; then
    echo "사용법: $0 <구현체명> <프레임번호>"
    echo "예: $0 node 13"
    exit 1
fi

impl=$1
frame_num=$2

BASE_DIR="/root/opcua-research"
PCAP_DIR="${BASE_DIR}/pcaps"
attack_file="${PCAP_DIR}/${impl}_attack.pcap"

if [ ! -f "$attack_file" ]; then
    echo "파일을 찾을 수 없습니다: $attack_file"
    exit 1
fi

echo "=== 평문 자격증명 검색 ==="
echo "파일: $attack_file"
echo "프레임 번호: $frame_num"
echo ""

# 헥스 덤프
echo "헥스 덤프:"
tshark -r "$attack_file" -x -Y "frame.number == $frame_num" 2>/dev/null

echo ""
echo "자격증명 키워드 검색:"
tshark -r "$attack_file" -Y "frame.number == $frame_num" 2>/dev/null | \
    nl -ba | grep -iE "testuser|password|UserNameIdentityToken|usernamePassword|SecurityPolicy#None" -C 3
