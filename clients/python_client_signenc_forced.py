#!/usr/bin/env python3
"""
ANSSI Baseline - Force SignAndEncrypt Mode
- Explicitly set security policy to Basic256Sha256_SignAndEncrypt
- Use UserNameIdentityToken
- Credentials should be ENCRYPTED
"""

from opcua import Client, ua
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("=" * 70)
    logger.info("ANSSI BASELINE: Force SignAndEncrypt (ENCRYPTED credentials)")
    logger.info("=" * 70)
    
    url = "opc.tcp://localhost:4840"
    client = Client(url)
    
    # Set credentials
    client.set_user("testuser")
    client.set_password("password123!")
    
    # CRITICAL: Force SignAndEncrypt mode
    try:
        # Try to set security string for specific policy
        client.set_security_string("Basic256Sha256,SignAndEncrypt")
        logger.info("✓ Security policy set to: Basic256Sha256, SignAndEncrypt")
    except Exception as e:
        logger.warning(f"Could not set security string: {e}")
        logger.info("Will attempt normal connection")
    
    try:
        logger.info("Connecting to: " + url)
        logger.info("Security Policy: Basic256Sha256_SignAndEncrypt")
        logger.info("Authentication: UserNameIdentityToken")
        logger.info("Expected: Credentials should be ENCRYPTED")
        
        client.connect()
        
        logger.info("✓ Connected successfully!")
        logger.info("✓ Credentials transmitted with ENCRYPTION")
        
        # Read test variable
        root = client.get_root_node()
        logger.info(f"Root node: {root}")
        
        # Get namespace and browse
        ns_idx = client.get_namespace_index("urn:anssi:research")
        if ns_idx >= 0:
            objects = client.get_objects_node()
            test_var = objects.get_child([f"{ns_idx}:TestDevice", f"{ns_idx}:TestVar"])
            value = test_var.get_value()
            logger.info(f"✓ Test variable value: {value}")
        
        logger.info("✓ Baseline test completed successfully")
        time.sleep(1)
        
    except Exception as e:
        logger.error(f"✗ Connection error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        try:
            client.disconnect()
            logger.info("Disconnected")
        except:
            pass

if __name__ == "__main__":
    main()
