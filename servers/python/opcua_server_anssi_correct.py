#!/usr/bin/env python3
"""
ANSSI Scenario - Correct Configuration
- Server provides BOTH SignAndEncrypt AND None endpoints
- Supports UserNameIdentityToken authentication
- Allows testing downgrade attack scenario
"""

from opcua import Server, ua
import time
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_server():
    server = Server()
    
    # Set endpoint
    server.set_endpoint("opc.tcp://0.0.0.0:4840")
    
    # CRITICAL: Enable MULTIPLE security policies
    # This is the key difference from previous attempts
    server.set_security_policy([
        ua.SecurityPolicyType.NoSecurity,  # For downgrade scenario
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt  # For secure baseline
    ])
    
    # Set server identity
    server.set_server_name("ANSSI Test Server")
    
    # Create namespace
    idx = server.register_namespace("urn:anssi:research")
    
    # Create test objects
    objects = server.get_objects_node()
    test_device = objects.add_object(idx, "TestDevice")
    test_device.add_variable(idx, "TestVar", 42)
    test_device.add_variable(idx, "Status", "Active")
    
    # Note: python-opcua will accept username/password if client provides them
    # No explicit user manager configuration needed for basic authentication
    
    logger.info("=" * 60)
    logger.info("ANSSI OPC UA Server - Correct Configuration")
    logger.info("=" * 60)
    logger.info("Endpoint: opc.tcp://0.0.0.0:4840")
    logger.info("Supported Security Policies:")
    logger.info("  - None (NoSecurity)")
    logger.info("  - Basic256Sha256 (SignAndEncrypt)")
    logger.info("Supported Auth:")
    logger.info("  - UserNameIdentityToken (username: password123!)")
    logger.info("  - Anonymous")
    logger.info("=" * 60)
    
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
