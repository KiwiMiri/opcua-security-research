#!/bin/bash
# 논문용 캡션 자동 생성

if [ $# -lt 3 ]; then
    echo "사용법: $0 <구현체명> <프레임번호> <오프셋시작-오프셋끝>"
    echo "예: $0 node 13 0x00E0-0x00F0"
    exit 1
fi

impl=$1
frame=$2
offsets=$3

echo "============================================"
echo "논문용 캡션 생성"
echo "============================================"
echo ""
echo "구현체: $impl"
echo "프레임: $frame"
echo "오프셋: $offsets"
echo ""

# 영어 캡션
echo "--- English Caption ---"
echo "Fig. X — Wireshark hex/ASCII dump of ActivateSession (Frame $frame) showing UserNameIdentityToken.Password in plaintext at ASCII offset $offsets. Baseline capture shows the same field as an encrypted blob under Basic256Sha256."
echo ""

# 한글 캡션
echo "--- Korean Caption ---"
echo "그림 X — ActivateSession 헥스/ASCII 덤프(프레임 $frame). ASCII 오프셋 $offsets에서 UserNameIdentityToken.Password가 평문으로 전송됨. 대비되는 정상 캡처에서는 동일 필드가 Basic256Sha256로 암호화되어 있음."
echo ""

# 본문 인용문 (영어)
echo "--- English Body Text ---"
echo "For each implementation (python-opcua, open62541, node-opcua, FreeOpcUa, Eclipse Milo), we captured both baseline (encrypted-only) and attack (forced downgrade) traces. In baseline captures, the ActivateSession UserNameIdentityToken appeared as an encrypted blob; after the downgrade to SecurityPolicy=None, the same field revealed plaintext credentials (e.g., $impl-opcua/Frame $frame, ASCII $offsets)."
echo ""

# 본문 인용문 (한글)
echo "--- Korean Body Text ---"
echo "각 구현체(python-opcua, open62541, node-opcua, FreeOpcUa, Eclipse Milo)에 대해 정상(암호화-only) 와 공격(강제 다운그레이드) 트래픽을 개별 pcap으로 수집하였다. 정상 캡처에서는 ActivateSession의 UserNameIdentityToken이 암호화된 blob으로만 관찰되었으나, 공격 캡처에서는 SecurityPolicy가 None으로 전환된 이후 동일 필드에서 평문 자격증명(Username/Password) 이 관찰되었다(예: $impl-opcua/프레임 $frame, ASCII $offsets)."
echo ""
