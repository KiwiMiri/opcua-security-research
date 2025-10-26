const { OPCUAClient } = require("node-opcua");

async function testClient(endpoint, name) {
    const client = OPCUAClient.create({});
    
    try {
        await client.connect(endpoint);
        console.log(`[${name}] 연결 성공: ${endpoint}`);
        
        const session = await client.createSession();
        console.log(`[${name}] 세션 생성 성공`);
        
        await session.close();
        await client.disconnect();
        return true;
    } catch (err) {
        console.log(`[${name}] 연결 실패:`, err.message);
        return false;
    }
}

async function main() {
    await testClient("opc.tcp://localhost:4840/freeopcua/server/", "Python Server");
    await testClient("opc.tcp://localhost:4841/UA/ResearchServer", "Node.js Server");
    await testClient("opc.tcp://localhost:4842", "open62541 Server");
    await testClient("opc.tcp://localhost:4843/freeopcua/server/", "FreeOpcUa Server");
    await testClient("opc.tcp://localhost:4844/UA/ResearchServer", "Eclipse Milo Server");
    
    process.exit(0);
}

main();
