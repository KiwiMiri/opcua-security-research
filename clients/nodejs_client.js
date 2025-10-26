const { OPCUAClient, UserIdentityInfo, MessageSecurityMode, SecurityPolicy } = require("node-opcua");

async function main() {
    const endpoint = "opc.tcp://127.0.0.1:4841/UA/ResearchServer";
    const username = "testuser";
    const password = "password123!";
    
    console.log(`서버 연결 중: ${endpoint}`);
    console.log(`사용자: ${username}`);
    console.log("Sending plain-text password");
    
    const client = OPCUAClient.create({
        endpointMustExist: false,
        connectionStrategy: {
            initialDelay: 100,
            maxRetry: 1
        }
    });
    
    try {
        await client.connect(endpoint);
        console.log("✓ 연결 성공");
        
        // UserNameIdentityToken 생성
        const userIdentity = {
            type: "UserName",
            userName: username,
            password: password
        };
        
        const session = await client.createSession(userIdentity);
        console.log("✓ 세션 생성 성공");
        
        // 간단한 읽기
        const browseResult = await session.browse("RootFolder");
        console.log("✓ 브라우즈 성공:", browseResult.references.length, "개 참조");
        
        await session.close();
    } catch (err) {
        console.error("✗ 실패:", err.message);
        if (err.stack) {
            console.error(err.stack.split('\n').slice(0, 5).join('\n'));
        }
    } finally {
        await client.disconnect();
        console.log("연결 종료");
    }
}

main().catch(err => {
    console.error("예상치 못한 오류:", err);
    process.exit(1);
});
