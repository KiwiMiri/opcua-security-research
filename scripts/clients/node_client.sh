#!/bin/bash
cd /root/opcua-research
cat > /tmp/node_client_test.js <<'JS'
const { OPCUAClient } = require("node-opcua");

async function test(endpoint, name) {
    const client = OPCUAClient.create({ endpointMustExist: false });
    try {
        await client.connect(endpoint);
        console.log(`[${name}] 연결 성공`);
        const session = await client.createSession();
        console.log(`[${name}] 세션 생성`);
        await session.close();
        await client.disconnect();
    } catch (err) {
        console.log(`[${name}] 연결 실패:`, err.message);
    }
}

(async () => {
    await test("opc.tcp://localhost:4841/UA/ResearchServer", "Node.js Server");
    process.exit(0);
})();
JS
cd servers/nodejs && node /tmp/node_client_test.js
