#!/usr/bin/env bash
# Analyze existing PCAP files and generate TSV data

set -euo pipefail

PCAP_DIR="pcaps"
OUTPUT_TSV="pcap_analysis_results.tsv"
FRAMES_DIR="frames"
mkdir -p "$FRAMES_DIR"

# TSV header
cat > "$OUTPUT_TSV" << 'EOF'
implementation	language	version	test_type	frame_number	hex_offset	observation	security_policy_offered	plaintext_credentials_found	pcap_file	notes
EOF

# Function to analyze a PCAP
analyze_pcap() {
    local pcap_file="$1"
    local impl=$(basename "$pcap_file" .pcap | cut -d'_' -f1)
    
    echo "=== Analyzing $pcap_file ==="
    
    # Check file size
    size=$(stat -c%s "$pcap_file" 2>/dev/null || echo 0)
    if [ "$size" -lt 100 ]; then
        echo "$impl\tUnknown\tUnknown\tN/A\t-\t-\tEmpty PCAP (< 100 bytes)\tN/A\tNo\t$(basename $pcap_file)\tFile too small" >> "$OUTPUT_TSV"
        return
    fi
    
    # Count packets
    packet_count=$(tshark -r "$pcap_file" -T fields -e frame.number 2>/dev/null | tail -1 || echo "0")
    
    if [ "$packet_count" = "0" ]; then
        echo "$impl\tUnknown\tUnknown\tN/A\t-\t-\tNo packets captured\tN/A\tNo\t$(basename $pcap_file)\tEmpty capture" >> "$OUTPUT_TSV"
        return
    fi
    
    # Check for OPC UA messages
    opcua_count=$(tshark -r "$pcap_file" -Y "opcua" 2>/dev/null | wc -l || echo "0")
    
    if [ "$opcua_count" = "0" ]; then
        echo "$impl\tUnknown\tUnknown\tN/A\t-\t-\tNo OPC UA messages\tN/A\tNo\t$(basename $pcap_file)\tNo OPC UA protocol" >> "$OUTPUT_TSV"
        return
    fi
    
    # Analyze ActivateSession for plaintext credentials
    activate_frames=$(tshark -r "$pcap_file" -Y "opcua.ActivateSession" -T fields -e frame.number 2>/dev/null || echo "")
    
    plaintext_found="No"
    frame_num="-"
    offset="-"
    observation="-"
    
    if [ -n "$activate_frames" ]; then
        # Check for plaintext credentials
        strings_output=$(strings "$pcap_file" 2>/dev/null | grep -iE "testuser|password|UserNameIdentityToken" | head -1 || echo "")
        
        if [ -n "$strings_output" ]; then
            plaintext_found="Yes"
            frame_num=$(echo "$activate_frames" | head -1)
            offset="Detected"
            observation="Credentials visible in strings"
        fi
    fi
    
    # Get endpoint info
    endpoint_info=$(tshark -r "$pcap_file" -Y "opcua.GetEndpointsResponse" 2>/dev/null | head -1 || echo "Not captured")
    
    # Determine test type
    test_type="unknown"
    if echo "$pcap_file" | grep -q "attack"; then
        test_type="attack"
    elif echo "$pcap_file" | grep -q "normal"; then
        test_type="normal"
    fi
    
    echo "$impl\tUnknown\tUnknown\t$test_type\t$frame_num\t$offset\t$observation\t$endpoint_info\t$plaintext_found\t$(basename $pcap_file)\tCaptured $packet_count packets, $opcua_count OPC UA messages" >> "$OUTPUT_TSV"
}

# Analyze all PCAP files
for pcap in "$PCAP_DIR"/*.pcap; do
    if [ -f "$pcap" ]; then
        analyze_pcap "$pcap"
    fi
done

echo ""
echo "=== TSV Output ==="
cat "$OUTPUT_TSV"
echo ""
echo "Results saved to $OUTPUT_TSV"
