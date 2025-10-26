#!/bin/bash
# OPC UA 구현체 메타데이터 수집 스크립트

set -e

OUTPUT="METADATA_COMPLETE.txt"
echo "# OPC UA 구현체 완전한 메타데이터" > $OUTPUT
echo "# 생성 일시: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> $OUTPUT
echo "" >> $OUTPUT

echo "Collecting metadata..."

# 1. Python-opcua
echo "## 1. Python-opcua" >> $OUTPUT
echo "Package: opcua" >> $OUTPUT
pip show opcua | grep -E "^Version|^Location|^Requires" >> $OUTPUT
echo "Version check:" >> $OUTPUT
python3 -c "import opcua; print('__file__:', opcua.__file__)" 2>/dev/null >> $OUTPUT || echo "__file__: not available" >> $OUTPUT
echo "" >> $OUTPUT

# 2. FreeOpcUa
echo "## 2. FreeOpcUa" >> $OUTPUT
pip show freeopcua 2>/dev/null | grep -E "^Version|^Location" >> $OUTPUT || echo "Not installed" >> $OUTPUT
echo "" >> $OUTPUT

# 3. Node.js opcua
echo "## 3. Node.js opcua" >> $OUTPUT
npm list -g node-opcua 2>&1 | head -3 >> $OUTPUT
echo "" >> $OUTPUT

# 4. Eclipse Milo
echo "## 4. Eclipse Milo" >> $OUTPUT
if [ -f "servers/eclipse-milo/opcua-server/pom.xml" ]; then
    echo "Version:" >> $OUTPUT
    grep -A 2 "<artifactId>sdk-server" servers/eclipse-milo/opcua-server/pom.xml | grep version >> $OUTPUT || echo "version: N/A" >> $OUTPUT
    echo "Java version:" >> $OUTPUT
    java -version 2>&1 | head -1 >> $OUTPUT
    echo "Maven version:" >> $OUTPUT
    mvn -version 2>&1 | head -1 >> $OUTPUT
else
    echo "Maven project not found" >> $OUTPUT
fi
echo "" >> $OUTPUT

# 5. S2OPC
echo "## 5. S2OPC" >> $OUTPUT
if [ -d "servers/s2opc/.git" ]; then
    cd servers/s2opc
    echo "Git commit:" >> ../../$OUTPUT
    git log -1 --format="  Hash: %H%n  Short: %h%n  Date: %ci%n  Message: %s" >> ../../$OUTPUT
    echo "" >> ../../$OUTPUT
    echo "Build environment:" >> ../../$OUTPUT
    gcc --version 2>&1 | head -1 >> ../../$OUTPUT || echo "gcc: not found" >> ../../$OUTPUT
    cmake --version 2>&1 | head -1 >> ../../$OUTPUT || echo "cmake: not found" >> ../../$OUTPUT
    cd ../..
fi
echo "" >> $OUTPUT

# 6. open62541
echo "## 6. open62541" >> $OUTPUT
if [ -f "servers/open62541/server.c" ]; then
    echo "Binary: servers/open62541/server.c (source file)" >> $OUTPUT
    sha256sum servers/open62541/server.c >> $OUTPUT
else
    echo "Binary: not found" >> $OUTPUT
fi
echo "" >> $OUTPUT

# 7. System environment
echo "## 7. System Environment" >> $OUTPUT
echo "OS:" >> $OUTPUT
uname -a >> $OUTPUT
echo "" >> $OUTPUT
echo "Python version:" >> $OUTPUT
python3 --version >> $OUTPUT
echo "" >> $OUTPUT
echo "Node version:" >> $OUTPUT
node --version >> $OUTPUT
echo "" >> $OUTPUT

# 8. PCAP files
echo "## 8. PCAP Files (SHA256)" >> $OUTPUT
find pcaps -name "*.pcap" -type f | while read f; do
    echo "File: $f" >> $OUTPUT
    sha256sum "$f" >> $OUTPUT
    echo "" >> $OUTPUT
done
echo "" >> $OUTPUT

# 9. Binary executables SHA256
echo "## 9. Binary Executables (SHA256)" >> $OUTPUT
find servers -type f -executable | grep -E "(\.py|\.js|server)" | head -10 | while read f; do
    if [ -f "$f" ]; then
        echo "File: $f" >> $OUTPUT
        sha256sum "$f" >> $OUTPUT
    fi
done
echo "" >> $OUTPUT

echo "Metadata collection complete: $OUTPUT"
cat $OUTPUT
