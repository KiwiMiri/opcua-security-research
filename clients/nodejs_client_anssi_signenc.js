#!/usr/bin/env node
/**
 * Node.js ANSSI Client - Force SignAndEncrypt
 * Tests ANSSI scenario with SignAndEncrypt mode
 */

const { OPCUAClient, MessageSecurityMode, SecurityPolicy, UserIdentityInfo } = require("node-opcua");

async function main() {
    console.log("=".repeat(70));
    console.log("Node.js ANSSI Client - SignAndEncrypt (ENCRYPTED credentials)");
    console.log("=".repeat(70));
    
    const endpoint = "opc.tcp://localhost:4842/UA/ResearchServer";
    
    const client = OPCUAClient.create({
        endpointMustExist: false,
        connectionStrategy: {
            initialDelay: 100,
            maxRetry: 1
        },
        securityMode: MessageSecurityMode.SignAndEncrypt,  // Force SignAndEncrypt
        securityPolicy: SecurityPolicy.Basic256Sha256       // Force Basic256Sha256
    });
    
    try {
        console.log("Connecting to:", endpoint);
        console.log("Security Mode: SignAndEncrypt");
        console.log("Security Policy: Basic256Sha256");
        console.log("Authentication: UserNameIdentityToken");
        console.log("Expected: Credentials should be ENCRYPTED");
        
        await client.connect(endpoint);
        console.log("✓ Connected");
        
        // UserNameIdentityToken
        const userIdentity = {
            type: "UserName",
            userName: "testuser",
            password: "password123!"
        };
        
        const session = await client.createSession(userIdentity);
        console.log("✓ Session created with UserNameIdentityToken");
        
        // Browse
        const browseResult = await session.browse("RootFolder");
        console.log("✓ Browsed", browseResult.references.length, "references");
        
        console.log("✓ ANSSI SignAndEncrypt test completed successfully");
        
        await session.close();
        
    } catch (err) {
        console.error("✗ Error:", err.message);
        if (err.stack) {
            console.error(err.stack.split('\n').slice(0, 5).join('\n'));
        }
    } finally {
        await client.disconnect();
        console.log("Disconnected");
    }
}

main().catch(err => {
    console.error("Fatal error:", err);
    process.exit(1);
});
