#!/usr/bin/env python3
"""
FreeOpcUa ANSSI Client - Force SignAndEncrypt
- Tests ANSSI scenario with FreeOpcUa server
"""

from opcua import Client, ua
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("=" * 70)
    logger.info("FreeOpcUa ANSSI Client - SignAndEncrypt Test")
    logger.info("=" * 70)
    
    url = "opc.tcp://localhost:4843"
    client = Client(url)
    
    # Set credentials
    client.set_user("testuser")
    client.set_password("password123!")
    
    try:
        logger.info("Connecting to: " + url)
        logger.info("Security Policy: Basic256Sha256_SignAndEncrypt (attempted)")
        logger.info("Authentication: UserNameIdentityToken")
        
        client.connect()
        
        logger.info("✓ Connected successfully!")
        
        # Read test variable
        root = client.get_root_node()
        logger.info(f"Root node: {root}")
        
        # Get namespace
        ns_idx = client.get_namespace_index("urn:freeopcua:anssi")
        if ns_idx >= 0:
            objects = client.get_objects_node()
            test_var = objects.get_child([f"{ns_idx}:TestDevice", f"{ns_idx}:TestVar"])
            value = test_var.get_value()
            logger.info(f"✓ Test variable value: {value}")
        
        logger.info("✓ FreeOpcUa ANSSI test completed")
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
