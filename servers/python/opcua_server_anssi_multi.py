#!/usr/bin/env python3
"""
ANSSI Scenario OPC UA Server
- Supports all 3 security modes: None, Sign, SignAndEncrypt
- Allows clients to choose their preferred security level
- Purpose: Demonstrate downgrade attack scenario
"""

from opcua import Server, ua
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_server():
    server = Server()
    
    # Set endpoint with all security modes
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # IMPORTANT: Enable all security policies for ANSSI scenario
    # This allows clients to negotiate any security level
    server.set_security_policy([
        ua.SecurityPolicyType.NoSecurity,  # None mode
        ua.SecurityPolicyType.Basic256Sha256_Sign,  # Sign mode  
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt  # SignAndEncrypt mode
    ])
    
    # Set server identity
    server.set_server_name("ANSSI Test Server")
    
    # Create namespace
    idx = server.register_namespace("urn:anssi:research")
    
    # Create objects and variables
    objects = server.get_objects_node()
    
    test_device = objects.add_object(idx, "TestDevice")
    test_device.add_variable(idx, "TestVar", 42)
    
    # Create authentication users
    server.set_security_IDs(["Anonymous", "username"])
    
    logger.info("=== ANSSI OPC UA Server Started ===")
    logger.info("Endpoint: opc.tcp://0.0.0.0:4840")
    logger.info("Supported Security Modes: None, Sign, SignAndEncrypt")
    logger.info("WARNING: This server allows plaintext credential transmission!")
    
    return server

def main():
    server = create_server()
    
    try:
        server.start()
        logger.info("Server running. Press Ctrl+C to stop...")
        
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        logger.info("\nShutting down server...")
    finally:
        server.stop()
        logger.info("Server stopped.")

if __name__ == "__main__":
    main()
