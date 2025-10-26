#!/bin/bash

cd "$(dirname "$0")"

echo "=== Eclipse Milo OPC UA Server ==="
echo "Building with Maven..."

# Maven 빌드
mvn clean compile > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: Maven 빌드 실패"
    exit 1
fi

echo "Starting server on port 4844..."

# 클래스패스 구성
CP="target/classes:$(mvn dependency:build-classpath -q -DincludeScope=runtime 2>/dev/null | grep -v '^\[INFO\]')"

# 서버 실행
java -cp "$CP" org.eclipse.milo.Server
