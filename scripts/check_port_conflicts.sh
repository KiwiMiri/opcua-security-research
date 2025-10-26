#!/bin/bash
# Check for port conflicts and suggest available ports

echo "=== OPC UA Server Port Status Check ==="
echo ""

echo "Currently used ports:"
ss -tunlp 2>/dev/null | grep -E "4840|4841|4842|4843|4844|4845|4850" || echo "  (none found)"
echo ""

echo "Recommended port assignments:"
echo "  4840 - Python-opcua (ANSSI scenario)"
echo "  4841 - Node.js opcua"
echo "  4842 - FreeOpcUa"
echo "  4843 - (available)"
echo "  4844 - Eclipse Milo"
echo "  4845 - (available)"
echo "  4850 - Python-opcua ANSSI (alternative)"
echo ""

echo "=== Conflict Detection ==="
PORTS="4840 4841 4842 4843 4844 4845 4850"
for port in $PORTS; do
    count=$(ss -tunlp 2>/dev/null | grep -c ":$port " || echo "0")
    if [ "$count" -gt "0" ]; then
        echo "  ⚠️  Port $port: IN USE"
        ss -tunlp 2>/dev/null | grep ":$port "
    fi
done

echo ""
echo "Note: Only one server can run per port at a time."
