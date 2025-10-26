#!/usr/bin/env python3
"""
Get Endpoints Info for all OPC UA servers
Collects offered security policies and modes from each server
"""

from opcua import Client
import json

SERVERS = [
    {"name": "python-opcua", "port": 4840},
    {"name": "open62541", "port": 4841},
    {"name": "node-opcua", "port": 4842},
    {"name": "freeopcua", "port": 4843},
    {"name": "eclipse-milo", "port": 4844},
]

def get_endpoints(server_name, port):
    """Get endpoints from a server"""
    url = f"opc.tcp://localhost:{port}"
    print(f"\n=== {server_name} (port {port}) ===")
    
    try:
        client = Client(url)
        client.connect()
        
        # Get endpoints (requires connection)
        endpoints = client.get_endpoints()
        
        print(f"Found {len(endpoints)} endpoints:")
        
        for i, ep in enumerate(endpoints):
            print(f"  Endpoint {i}:")
            print(f"    URL: {ep.EndpointUrl}")
            print(f"    SecurityMode: {ep.SecurityMode}")
            print(f"    SecurityPolicyUri: {ep.SecurityPolicyUri}")
            print(f"    UserIdentityTokens: {len(ep.UserIdentityTokens)} tokens")
        
        client.disconnect()
        return endpoints
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def main():
    print("Collecting endpoint information from all servers...")
    
    results = {}
    for server in SERVERS:
        endpoints = get_endpoints(server["name"], server["port"])
        if endpoints:
            results[server["name"]] = {
                "count": len(endpoints),
                "endpoints": [
                    {
                        "url": ep.EndpointUrl,
                        "security_mode": str(ep.SecurityMode),
                        "security_policy": ep.SecurityPolicyUri
                    }
                    for ep in endpoints
                ]
            }
    
    # Print summary
    print("\n=== Summary ===")
    for name, data in results.items():
        print(f"{name}: {data['count']} endpoints")
        for ep in data['endpoints']:
            print(f"  - {ep['security_policy']} ({ep['security_mode']})")
    
    # Save to JSON
    with open('endpoints_info.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    print("\nResults saved to endpoints_info.json")

if __name__ == "__main__":
    main()
