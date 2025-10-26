#!/usr/bin/env python3
"""
ANSSI Attack Scenario - Plaintext Credentials
- Force None mode (NoSecurity)
- Use UserNameIdentityToken
- Credentials will be transmitted in PLAINTEXT
"""

from opcua import Client, ua
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("=" * 60)
    logger.info("ATTACK: Plaintext Transmission (NoSecurity)")
    logger.info("=" * 60)
    
    client = Client("opc.tcp://localhost:4840")
    
    # Set credentials
    client.set_user("username")
    client.set_password("password123!")
    
    try:
        logger.info("Connecting with USERNAME/PASSWORD auth...")
        logger.info("Security Policy: None (NoSecurity)")
        logger.info("WARNING: Credentials will be transmitted in PLAINTEXT!")
        
        client.connect()
        
        logger.info("✓ Connected!")
        logger.info("CREDENTIALS TRANSMITTED IN PLAINTEXT!")
        
        # Read test variable
        root = client.get_root_node()
        logger.info(f"Root node: {root}")
        
        # Get namespace
        ns_idx = client.get_namespace_index("urn:anssi:research")
        objects = client.get_objects_node()
        
        # Find test device
        test_var = objects.get_child([f"{ns_idx}:TestDevice", f"{ns_idx}:TestVar"])
        value = test_var.get_value()
        logger.info(f"Test variable value: {value}")
        
        logger.info("✓ Attack scenario completed")
        time.sleep(1)
        
    except Exception as e:
        logger.error(f"Connection error: {e}")
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
