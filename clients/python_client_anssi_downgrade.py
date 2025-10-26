#!/usr/bin/env python3
"""
ANSSI Downgrade Attack Client
- Scenario A: Connect with SignAndEncrypt (secure baseline)
- Scenario B: Force connection with None (downgrade simulation)
"""

from opcua import Client, ua
import sys
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_secure_connection():
    """Scenario A: SignAndEncrypt (normal/baseline)"""
    logger.info("=" * 60)
    logger.info("SCENARIO A: Secure Connection (SignAndEncrypt)")
    logger.info("=" * 60)
    
    client = Client("opc.tcp://localhost:4850")
    
    try:
        logger.info("Connecting with SignAndEncrypt security mode...")
        client.connect()
        
        logger.info("Connected! Reading root node...")
        root = client.get_root_node()
        logger.info(f"Root node: {root}")
        
        # Try username/password authentication
        client.set_user("testuser")
        client.set_password("testpassword")
        
        logger.info("Connected with encrypted channel")
        time.sleep(1)
        
    except Exception as e:
        logger.error(f"Connection error: {e}")
    finally:
        try:
            client.disconnect()
        except:
            pass
        logger.info("Disconnected")

def test_downgrade_connection():
    """Scenario B: None mode (downgrade attack simulation)"""
    logger.info("=" * 60)
    logger.info("SCENARIO B: Downgrade Attack (None mode)")
    logger.info("=" * 60)
    
    client = Client("opc.tcp://localhost:4850")
    
    # Set username/password BEFORE connecting
    client.set_user("testuser")
    client.set_password("testpassword")
    
    try:
        logger.info("Connecting with None security mode (PLAINTEXT)...")
        logger.info("WARNING: Credentials will be transmitted in PLAINTEXT!")
        
        # Manually connect and select None endpoint
        client.connect_socket()
        client.send_hello()
        client.open_secure_channel()
        
        # Get endpoints
        endpoints = client.get_endpoints()
        logger.info(f"Found {len(endpoints)} endpoints")
        
        # Find None mode endpoint
        none_endpoint = None
        for ep in endpoints:
            logger.info(f"Endpoint: {ep.SecurityMode} - {ep.SecurityPolicyUri}")
            if ep.SecurityMode == ua.MessageSecurityMode.None_:
                none_endpoint = ep
                break
        
        if none_endpoint:
            logger.info(f"✓ Selected None endpoint: {none_endpoint.EndpointUrl}")
            # Create session with username/password (will be in plaintext!)
            client.create_session()
            client.activate_session()
            logger.info("CREDENTIALS TRANSMITTED IN PLAINTEXT!")
        else:
            logger.warning("No None endpoint found, trying regular connect...")
            client.close_secure_channel()
            client.disconnect_socket()
            client.connect()
        
        time.sleep(1)
        
    except Exception as e:
        logger.error(f"Connection error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        try:
            client.disconnect()
        except:
            pass
        logger.info("Disconnected")

def main():
    if len(sys.argv) > 1:
        mode = sys.argv[1].lower()
    else:
        mode = "both"
    
    if mode in ["secure", "a", "both"]:
        test_secure_connection()
    
    if mode in ["downgrade", "b", "both"]:
        time.sleep(2)
        test_downgrade_connection()
    
    logger.info("\n" + "=" * 60)
    logger.info("ANSSI Scenario Test Complete")
    logger.info("=" * 60)
    logger.info("\nNext steps:")
    logger.info("1. Capture network traffic with tcpdump during each scenario")
    logger.info("2. Analyze pcap files to find plaintext credentials")
    logger.info("3. Compare encrypted vs plaintext packet dumps")

if __name__ == "__main__":
    main()
