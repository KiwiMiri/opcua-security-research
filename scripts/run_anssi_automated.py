#!/usr/bin/env python3
"""
ANSSI Automated Test Runner
- Starts server with all security modes
- Runs baseline (None), encrypted (SignAndEncrypt), and downgrade tests
- Captures network traffic for each scenario
- Generates analysis report
"""

import subprocess
import time
import sys
import os
from pathlib import Path

BASE_DIR = Path("/root/opcua-research")
PCAPS_DIR = BASE_DIR / "pcaps" / "anssi_scenario"
LOGS_DIR = BASE_DIR / "logs"

def run_command(cmd, background=False):
    """Run shell command"""
    if background:
        return subprocess.Popen(cmd, shell=True)
    else:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result

def main():
    print("=" * 80)
    print("ANSSI Scenario Automated Test")
    print("=" * 80)
    
    # Setup directories
    PCAPS_DIR.mkdir(parents=True, exist_ok=True)
    LOGS_DIR.mkdir(exist_ok=True)
    
    # Step 1: Start ANSSI server
    print("\n[1/6] Starting ANSSI OPC UA Server...")
    server = run_command(
        "cd /root/opcua-research && "
        "python3 servers/python/opcua_server_anssi_multi.py",
        background=True
    )
    time.sleep(3)
    print("✓ Server started on port 4850")
    
    # Step 2: Scenario A - Baseline (None mode)
    print("\n[2/6] Running Scenario A: Baseline (None mode - plaintext)...")
    run_command("sudo timeout 30 tcpdump -i any -s 0 -w {}/scenario_a_baseline.pcap 'tcp port 4850' &".format(PCAPS_DIR))
    tcpdump_a = subprocess.Popen(["sudo", "timeout", "30", "tcpdump", "-i", "any", "-s", "0", 
                                  "-w", str(PCAPS_DIR / "scenario_a_baseline.pcap"), "tcp", "port", "4850"])
    time.sleep(2)
    
    result = run_command("cd /root/opcua-research && python3 clients/python_client_anssi_downgrade.py downgrade")
    time.sleep(3)
    tcpdump_a.terminate()
    print("✓ Scenario A captured")
    
    # Step 3: Scenario B - Encrypted (SignAndEncrypt)
    print("\n[3/6] Running Scenario B: Encrypted (SignAndEncrypt)...")
    tcpdump_b = subprocess.Popen(["sudo", "timeout", "30", "tcpdump", "-i", "any", "-s", "0",
                                  "-w", str(PCAPS_DIR / "scenario_b_encrypted.pcap"), "tcp", "port", "4850"])
    time.sleep(2)
    
    result = run_command("cd /root/opcua-research && python3 clients/python_client_anssi_downgrade.py secure")
    time.sleep(3)
    tcpdump_b.terminate()
    print("✓ Scenario B captured")
    
    # Step 4: Analyze captures
    print("\n[4/6] Analyzing captures...")
    
    # Check for plaintext in baseline
    print("\n📊 Checking Scenario A (Baseline) for plaintext credentials...")
    result = run_command(f"strings {PCAPS_DIR}/scenario_a_baseline.pcap | grep -i 'testuser\\|testpassword'")
    if result.stdout:
        print("⚠️  PLAINTEXT CREDENTIALS FOUND in Scenario A!")
        print(result.stdout[:200])
    else:
        print("✗ No plaintext found (may need deeper analysis)")
    
    # Check encrypted in scenario B
    print("\n📊 Checking Scenario B (Encrypted) for plaintext credentials...")
    result = run_command(f"strings {PCAPS_DIR}/scenario_b_encrypted.pcap | grep -i 'testuser\\|testpassword'")
    if result.stdout:
        print("⚠️  WARNING: Plaintext found in encrypted scenario!")
    else:
        print("✓ No plaintext found (credentials properly encrypted)")
    
    # Step 5: Generate report
    print("\n[5/6] Generating analysis report...")
    report_path = BASE_DIR / "reports" / "anssi_analysis.txt"
    report_path.parent.mkdir(exist_ok=True)
    
    with open(report_path, 'w') as f:
        f.write("ANSSI Scenario Analysis Report\n")
        f.write("=" * 80 + "\n\n")
        f.write("Scenario A (Baseline - None mode):\n")
        f.write(f"  PCAP: {PCAPS_DIR}/scenario_a_baseline.pcap\n")
        f.write("  Expected: Plaintext credentials visible\n\n")
        f.write("Scenario B (Encrypted - SignAndEncrypt mode):\n")
        f.write(f"  PCAP: {PCAPS_DIR}/scenario_b_encrypted.pcap\n")
        f.write("  Expected: Encrypted blob, no plaintext\n\n")
        f.write("Next Steps:\n")
        f.write("1. Open PCAP files in Wireshark\n")
        f.write("2. Search for 'UserNameIdentityToken' frames\n")
        f.write("3. Compare hex dumps between scenarios\n")
        f.write("4. Extract frame numbers and offsets\n")
    
    print(f"✓ Report saved to {report_path}")
    
    # Step 6: Cleanup
    print("\n[6/6] Cleaning up...")
    server.terminate()
    print("✓ Server stopped")
    
    print("\n" + "=" * 80)
    print("ANSSI Automated Test Complete!")
    print("=" * 80)
    print(f"\nResults saved in: {PCAPS_DIR}")
    print(f"Report: {report_path}")
    print("\nTo analyze in detail:")
    print(f"  wireshark {PCAPS_DIR}/scenario_*.pcap")
    print(f"  tshark -r {PCAPS_DIR}/scenario_a_baseline.pcap -Y 'opcua' -x")

if __name__ == "__main__":
    main()
