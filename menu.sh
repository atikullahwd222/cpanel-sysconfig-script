#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}ERROR: curl is not installed. Please install curl and try again.${NC}"
    exit 1
fi

# Ensure we are running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Warning: You are not running as root. You may need to enter sudo passwords during installation.${NC}"
fi

# Create directory for t4s if it does not exist
echo -e "${GREEN}Creating Binaries...${NC}"
mkdir -p /usr/local/bin

clear
Theme4Sell_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh"

# Interactive menu
echo -e "    ____  __  __   _____            __               "
echo -e "   / __ )/ / / /  / ___/__  _______/ /____  ____ ___ "
echo -e "  / __  / /_/ /   \__ \/ / / / ___/ __/ _ \/ __ \`__ \\ "
echo -e " / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / /"
echo -e "/_____/_/_/_/_  /____/\__, /____/\__/\___/_/ /_/ /_/ "
echo -e "                     /____/                     V2.1 "
echo -e "                                                     "
echo -e ""
echo -e ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo ""
echo -e "${YELLOW}Do Basic Config part before start installation..${NC}"
echo -e "${YELLOW}Go to main menu for do the basic config.${NC}"
echo -e "${YELLOW}Press 0 to go back Main menu${NC}"
echo ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo ""
echo ""
echo -e "${YELLOW}1 - Do Basic Config (Ready the server for WHM)${NC} ${RED}!Important${NC}"
echo "2 - Budget Licensing System"
echo "3 - Change SSH port"
echo "4 - I just want to install WHM and Tweaks"
echo "0 - Exit"

read -p "Enter your choice (0-4): " choice

if [[ "$choice" == "1" ]]; then
    read -p "Enter the server IP: " server_ip
    read -p "Enter the hostname: " hostname
    read -p "Enter the hostname prefix: " hostname_prefix

    echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Installing Almalinux Relese.... ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    yum install almalinux-release -y

    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Installing nano ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    yum install nano -y
    
    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Updating Pacages.... ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    yum update -y 

    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Installing Curl and Perl Package.... ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    yum install perl curl -y

    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Setting Firewall settings for WHM.... ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    iptables-save > ~/firewall.rules
    systemctl stop firewalld.service
    systemctl disable firewalld.service

    echo ""
    echo ""
    echo ""
    echo -e "${YELLOW}Setting Timezone to Asia/Dhaka.... ${NC}"
    echo ""
    echo ""
    echo ""
    sleep 1
    timedatectl set-timezone Asia/Dhaka >/dev/null 2>&1


    clear

    echo -e "${RED}The Server needs a reboot.....${NC}"
    echo -e "${RED}Press Ctrl+C${NC} ${GREEN}to avoid restart${NC}"
    sleep 30
    echo -e "${GREEN}After reboot, run t4s again to continue.${NC}"
    echo -e "${RED}Rebooting...${NC}"
    sleep 3

    reboot now

elif [[ "$choice" == "2" ]]; then
    echo -e "${GREEN}You selected Theme4Sell.${NC}"
    echo -e "${YELLOW}Redirecting...${NC}"
    sleep 1
    bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        
elif [[ "$choice" == "3" ]]; then
    # Get the current SSH port number (it can be commented out or set)
    current_port=$(grep -E "^#?Port" /etc/ssh/sshd_config | awk '{print $2}' | head -n 1)
    
    # If there's no current port found, default it to 22
    if [[ -z "$current_port" ]]; then
        current_port=22
    fi
    
    echo "Current SSH port is: $current_port"
    
    # Prompt user to input a new port number
    read -p "Enter the new SSH port number: " new_port
    
    # Change the SSH port in the configuration file
    sudo sed -i "s/^#\?Port $current_port/Port $new_port/g" /etc/ssh/sshd_config && sudo systemctl restart sshd
    
    # Give a brief pause before running the next step
    sleep 3
    t4s

elif [[ "$choice" == "4" ]]; then
    echo -e "${GREEN}You selected WHM and Tweaks installation.${NC}"
    echo -e "${GREEN}We are Still working on it${NC}"
    sleep 3
    t4s

elif [[ "$choice" == "0" ]]; then
    clear
    echo -e "${GREEN}Exiting...${NC}"
    exit 0
else
    echo -e "${RED}Invalid option! Please select 1-4.${NC}"
    exit 0
fi