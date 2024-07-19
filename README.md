# Nmap Automation Script V2

## Introduction

Welcome to the Nmap Automation Script V2, created by Dark_Shadow04. This script is designed to automate network scans using Nmap, providing a comprehensive set of features for advanced users. It includes MAC address spoofing, decoy IP usage, and various Nmap scan techniques, making it an essential tool for cybersecurity professionals.

## Features

- **Automatic Sudo Relaunch:** Ensures the script runs with the necessary permissions.
- **Dependency Check and Installation:** Verifies and installs required dependencies (`nmap`, `enscript`, `parallel`, `macchanger`, `pv`).
- **MAC Address Spoofing:** Changes the MAC address for anonymity and reverts to the original MAC address after the script completes.
- **Target Availability Check:** Ensures the target is reachable before running scans.
- **Sequential and Parallel Command Execution:** Allows running commands one by one with user control or all at once in parallel.
- **Decoy IPs and Spoofed MAC:** Uses decoy IPs and MAC address spoofing to evade firewalls and IDS.
- **Progress Bar for Report Generation:** Provides a visual progress indicator during report generation.
- **Comprehensive Logging:** Maintains logs of script operations.
- **Full Report Generation:** Compiles individual scan reports into a single comprehensive report.
- **Script Rerun Prompt:** Allows the user to rerun the script upon completion.

## Requirements

- **Operating System:** Linux or macOS
- **Dependencies:** `nmap`, `enscript`, `parallel`, `macchanger`, `pv`
- **Internet Connection:** Required for installing dependencies

## Installation

Ensure you have the necessary permissions to install dependencies. The script will automatically check for and install missing dependencies.

```bash
sudo apt-get install nmap enscript parallel macchanger pv  # For Linux
brew install nmap enscript parallel macchanger pv          # For macOS
```

## Usage

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/DarkShadow04/nmap_auto_V2.git
   cd nmap_auto_V2
   ```

2. **Make the Script Executable:**
   ```bash
   chmod +x nmap_auto_V2.sh
   ```

3. **Run the Script:**
   ```bash
   sudo ./nmap_auto_V2.sh
   ```

4. **Follow the Prompts:**
   - Choose whether to run the script as root.
   - Enter the network interface (e.g., eth0, wlan0).
   - Enter the target IP or web address.
   - Choose whether to run commands sequentially or in parallel.
   - Confirm before running each command if running sequentially.

## Commands Used

The script uses various Nmap commands with different options for thorough network scanning:

- **Idle Scan:**
  ```bash
  nmap -P0 -sI 1.1.1.1:1234 $target
  ```
- **Service and Version Detection:**
  ```bash
  nmap -Pn -n -sS -A -T4 -D$decoy_ips --spoof-mac 0 $target
  nmap -Pn -n -sCV -A -D$decoy_ips --spoof-mac 0 $target
  ```
- **Full Port Scan:**
  ```bash
  nmap -Pn -n -p- -T4 -D$decoy_ips --spoof-mac 0 $target
  ```
- **Firewall and IDS Evasion:**
  ```bash
  nmap -Pn -sF -p1-100 -T4 -D$decoy_ips --spoof-mac 0 $target
  nmap -sS -v -v -Pn -g 88 -D$decoy_ips --spoof-mac 0 $target
  nmap --send-ip -v -v -Pn -D$decoy_ips --spoof-mac 0 $target
  nmap -f -D$decoy_ips --spoof-mac 0 $target
  nmap --source-port 88 -D$decoy_ips --spoof-mac 0 $target
  ```
- **Vulnerability Detection:**
  ```bash
  nmap -b -D$decoy_ips --spoof-mac 0 $target
  nmap --script=vuln -sV -O --script-args=unsafe=1 -D$decoy_ips --spoof-mac 0 $target
  nmap --script=ipidseq --script-args=ipid.zero=1 -v -v -Pn -D$decoy_ips --spoof-mac 0 $target
  nmap --script=firewall-bypass --script-args=unsafe=1 -D$decoy_ips --spoof-mac 0 $target
  ```

## Logs and Reports

- **Logs:** Saved in the `logs/` directory.
- **Full Reports:** Saved in the `full_reports/` directory, with individual command outputs and a combined full report.

## Author

**Dark_Shadow04**

- GitHub: [Dark_Shadow04](https://github.com/DarkShadow04)

## Disclaimer

Use this script responsibly and only on networks and devices you own or have explicit permission to test. Unauthorized scanning is illegal and unethical. The author is not responsible for any misuse or damage caused by this script.
