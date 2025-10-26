#!/usr/bin/env python3
"""
python-opcua - ANSSI Correct Configuration with Certificates
- Server provides BOTH SignAndEncrypt (with cert) AND None endpoints
- Enables UserNameIdentityToken authentication
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
    server.set_endpoint("opc.tcp://0.0.0.0:4843")
    
    # CRITICAL: Enable MULTIPLE security policies
    server.set_security_policy([
        ua.SecurityPolicyType.NoSecurity,  # For downgrade scenario
        ua.SecurityPolicyType.Basic256Sha256_SignAndEncrypt  # For secure baseline
    ])
    
    # Load certificates for SignAndEncrypt
    cert_dir = "/root/opcua-research/certs"
    cert_file = os.path.join(cert_dir, "server_cert.pem")
    key_file = os.path.join(cert_dir, "server_key.pem")
    
    if os.path.exists(cert_file) and os.path.exists(key_file):
        try:
            server.load_certificate(cert_file)
            server.load_private_key(key_file)
            logger.info("✓ Server certificates loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load certificates: {e}")
    else:
        logger.warning("Certificate files not found, SignAndEncrypt may not work properly")
    
    # Set server identity
    server.set_server_name("FreeOpcUa ANSSI Server")
    
    # Create namespace
    idx = server.register_namespace("urn:freeopcua:anssi")
    
    # Create test objects
    objects = server.get_objects_node()
    test_device = objects.add_object(idx, "TestDevice")
    test_device.add_variable(idx, "TestVar", 42)
    test_device.add_variable(idx, "Status", "Active")
    
    logger.info("=" * 70)
    logger.info("FreeOpcUa ANSSI Server - Certificate-based Configuration")
    logger.info("=" * 70)
    logger.info("Endpoint: opc.tcp://0.0.0.0:4843")
    logger.info("Supported Security Policies:")
    logger.info("  1. None (NoSecurity) - For downgrade attack demonstration")
    logger.info("  2. Basic256Sha256 (SignAndEncrypt) - For secure baseline")
    logger.info("Supported Authentication:")
    logger.info("  - UserNameIdentityToken")
    logger.info("  - Anonymous")
    logger.info("=" * 70)
    
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
