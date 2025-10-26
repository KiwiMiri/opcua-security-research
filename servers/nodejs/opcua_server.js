const { OPCUAServer } = require("node-opcua");

const server = new OPCUAServer({
    port: 4842,
    resourcePath: "/UA/ResearchServer",
    buildInfo: {
        productName: "OPC UA Research Server",
        buildNumber: "1.0.0"
    },
    allowAnonymous: true,
    userManager: {
        isValidUser: (username, password) => {
            console.log("인증 시도:", username, password ? `(password length: ${password.length})` : "(no password)");
            // ANSSI 테스트용: testuser / password123! 인증 허용
            if (username === "testuser" && password === "password123!") {
                console.log("✓ User authenticated successfully");
                return true;
            }
            if (username === "Anonymous") {
                return true;  // Anonymous 허용
            }
            console.log("✗ Authentication failed");
            return false;
        }
    }
});

// 서버 시작
server.start(() => {
    console.log("OPC UA 서버가 시작되었습니다.");
    console.log(`엔드포인트: ${server.getEndpointUrl()}`);
    
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
