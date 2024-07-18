#!/bin/bash

# Define text color for banner
color=("\033[1;31m" "\033[1;32m" "\033[1;33m" "\033[1;34m" "\033[1;35m" "\033[1;36m" "\033[1;37m")
random_color=${color[$RANDOM % ${#color[@]}]}
reset='\033[0m'

# Function to relaunch script as sudo if required
relaunch_as_sudo() {
    echo -e "\e[1;34mRelaunching script with sudo...\e[0m"
    exec sudo bash "$0" "sudo_relaunched" "$@"
}

# Check if the script is being relaunched with sudo
if [ "$1" != "sudo_relaunched" ]; then
# Print banner
echo -e "$random_color"
echo -e "_
 ██████   █████                                          █████████             █████                █████   █████ ████████ 
░░██████ ░░███                                          ███░░░░░███           ░░███                ░░███   ░░███ ███░░░░███
 ░███░███ ░███ █████████████    ██████  ████████       ░███    ░███ █████ ███████████    ██████     ░███    ░███░░░    ░███
 ░███░░███░███░░███░░███░░███  ░░░░░███░░███░░███      ░███████████░░███ ░███░░░███░    ███░░███    ░███    ░███   ███████ 
 ░███ ░░██████ ░███ ░███ ░███   ███████ ░███ ░███      ░███░░░░░███ ░███ ░███  ░███    ░███ ░███    ░░███   ███   ███░░░░  
 ░███  ░░█████ ░███ ░███ ░███  ███░░███ ░███ ░███      ░███    ░███ ░███ ░███  ░███ ███░███ ░███     ░░░█████░   ███      █
 █████  ░░██████████░███ █████░░████████░███████████████████   █████░░████████ ░░█████ ░░██████████████░░███    ░██████████
░░░░░    ░░░░░░░░░░ ░░░ ░░░░░  ░░░░░░░░ ░███░░░░░░░░░░░░░░░   ░░░░░  ░░░░░░░░   ░░░░░   ░░░░░░░░░░░░░░  ░░░     ░░░░░░░░░░ 
                                        ░███                                                                               
                                        █████                                                                              
_"

echo -e "${random_color} nmap_auto_V2 script by: Dark_Shadow04 ${reset}\n"
echo -e "${random_color} https://github.com/DarkShadow04  ${reset}\n"
echo -e "${random_color} Copyright 2023 Dark_Shadow04 ${reset}\n"
    
    # Ask if user wants to run the script as root
    echo -e "\e[1;34mDo you want to run the script as root? (yes/no)\e[0m"
    read run_as_root

    if [ "$run_as_root" = "yes" ]; then
        if [ "$EUID" -ne 0 ]; then
            relaunch_as_sudo "$@"
        fi
    fi
fi

# Dependencies check and installation
dependencies=("nmap" "enscript" "parallel" "macchanger" "pv")

for dependency in "${dependencies[@]}"; do
    if ! [ -x "$(command -v $dependency)" ]; then
        echo -e "\e[1;31mError: $dependency is not installed.\e[0m"
        if [ "$(uname)" == "Linux" ]; then
            echo -e "\e[1;34mInstalling $dependency...\e[0m"
            sudo apt-get install -y $dependency
        elif [ "$(uname)" == "Darwin" ];then
            echo -e "\e[1;34mInstalling $dependency...\e[0m"
            brew install $dependency
        else
            echo -e "\e[1;31mError: Unsupported operating system. Please install $dependency manually.\e[0m"
            exit 1
        fi
    fi
done

# Function to ensure log directory exists
ensure_log_directory() {
    mkdir -p logs
}

# Function to revert MAC address to original
revert_mac() {
    echo -e "\e[1;34mReverting MAC address...\e[0m"
    sudo macchanger -p $interface
}

# Get network interface
echo -e "\e[1;34mEnter network interface (e.g., eth0, wlan0):\e[0m"
read interface

# Change MAC address
echo -e "\e[1;34mChanging MAC address...\e[0m"
original_mac=$(macchanger -s $interface | awk '/Permanent/ {print $3}')
sudo macchanger -r $interface

# Get target
echo -e "\e[1;34mEnter target IP or Web address without https/http:\e[0m"
read target

# Check if target is alive
if ! ping -c 1 -W 1 $target > /dev/null; then
    echo -e "\e[1;31mError: Target is not reachable. Exiting...\e[0m"
    revert_mac
    exit 1
fi

# Ask if user wants to run all commands at once
echo -e "${random_color} ..Yes=Run command one by one with user control(Generated Report on the go), No=All commands at a time(Takes good amount of time to generate report)... ${reset}\n"
echo -e "\e[1;34mRun commands sequentially? (yes/no)\e[0m"
read run_all

# Create report directories
ensure_log_directory
mkdir -p full_reports/$target

# Set decoy IPs
decoy_ips="192.168.1.5,10.5.1.2,172.1.2.4,3.4.2.1"

# Set an array of commands
echo -e "${random_color}...Some Commands takes a lot of Time! Patience! or you can do ctrl+c to skip and generate the report...${reset}\n"
commands=(
    "nmap -P0 -sI 1.1.1.1:1234 $target"  # Idle scan example
    "nmap -Pn -n -sS -A -T4 -D$decoy_ips --spoof-mac 0 $target"
    "nmap -Pn -n -sCV -A -D$decoy_ips --spoof-mac 0 $target"
    "nmap -Pn -n -p- -T4 -D$decoy_ips --spoof-mac 0 $target"
    "nmap -Pn -sF -p1-100 -T4 -D$decoy_ips --spoof-mac 0 $target"
    "nmap -sS -v -v -Pn -g 88 -D$decoy_ips --spoof-mac 0 $target"
    "nmap --send-ip -v -v -Pn -D$decoy_ips --spoof-mac 0 $target"
    "nmap -f -D$decoy_ips --spoof-mac 0 $target"
    "nmap --source-port 88 -D$decoy_ips --spoof-mac 0 $target"
    "nmap -b -D$decoy_ips --spoof-mac 0 $target"
    "nmap --script=vuln -sV -O --script-args=unsafe=1 -D$decoy_ips --spoof-mac 0 $target"
    "nmap --script=ipidseq --script-args=ipid.zero=1 -v -v -Pn -D$decoy_ips --spoof-mac 0 $target"
    "nmap --script=firewall-bypass --script-args=unsafe=1 -D$decoy_ips --spoof-mac 0 $target"
)

# Function to run a command with user confirmation and log operations
run_command() {
    command=$1
    command_name=$(echo "$command" | tr ' ' '_')
    log_file="logs/script_log.txt"

    # Prompt user to confirm before running each command
    echo -e "\e[1;34mDo you want to run command '$command'? (yes/no)\e[0m"
    read confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "\e[1;31mSkipping command '$command'\e[0m"
        return
    fi

    # Log the command execution
    echo "$(date +"%Y-%m-%d %H:%M:%S"): Running command '$command'" >> $log_file

    # Execute the command and capture output
    echo -e "\e[1;34mRunning command: '$command'\e[0m"
    eval "$command" | tee "full_reports/$target/$command_name.txt"

    # Log the completion of the command
    echo "$(date +"%Y-%m-%d %H:%M:%S"): Command '$command' completed." >> $log_file
}

# Run commands sequentially or in parallel
if [ "$run_all" = "yes" ]; then
    echo -e "\e[1;34mRunning all commands sequentially...\e[0m"
    for command in "${commands[@]}"; do
        run_command "$command"
    done
else
    echo -e "\e[1;34mRunning commands in parallel...\e[0m"
    parallel --bar --joblog logs/parallel.log ::: "${commands[@]}"
    echo -e "\e[1;34mGenerating Reports...\e[0m"

    # Use pv to add a progress bar to report generation
    total_commands=${#commands[@]}
    counter=0

    for command in "${commands[@]}"; do
        counter=$((counter + 1))
        command_name=$(echo "$command" | tr ' ' '_')
        report_file="full_reports/$target/$command_name.txt"
        (eval $command > "$report_file" 2>&1 && enscript -q -fCourier8 -o - "$report_file" | ps2pdf - "full_reports/$target/$command_name.pdf") | pv -p -t -e -N "Progress: $counter/$total_commands" > /dev/null
    done

    echo -e "\e[1;34mAll commands completed.\e[0m"
fi

# Generate full report
echo -e "\e[1;34mGenerating Full Report...\e[0m"
if [ "$(ls full_reports/$target/*.txt 2>/dev/null)" ]; then
    cat full_reports/$target/*.txt > full_reports/$target.txt
    enscript -q -fCourier8 -o - full_reports/$target.txt | ps2pdf - full_reports/$target.pdf
    echo -e "\e[1;34mFull report saved in full_reports/ directory\e[0m"
else
    echo -e "\e[1;31mNo data found for $target. Full report not generated.\e[0m"
fi

# Revert MAC address to original
revert_mac

# Print script completion message
script_end_time=$(date)
echo -e "\e[1;34mLogs saved in logs/ directory\e[0m"
echo -e "\e[1;34mScript completed at $script_end_time.\e[0m"

# Prompt user to rerun the script
echo -e "\e[1;34mDo you want to rerun the script? (yes/no)\e[0m"
read rerun_script

if [ "$rerun_script" = "yes" ]; then
    exec "$0" "$@"  # Rerun the script with the same arguments
else
    echo -e "\e[1;34mExiting...\e[0m"
    exit 0
fi
