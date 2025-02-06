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
echo "Thanks for Choosing us. Go with ..."
echo -e "${YELLOW}1 - Do Basic Config (Ready the server for WHM)${NC} ${RED}!Important${NC}"
echo "2 - Theme4Sell v2"
echo "3 - GB Lic"
echo "4 - I just want to install WHM and Tweaks"
echo "0 - Exit"

read -p "Enter your choice (0-4): " choice

case $choice in
    1)
        server_ip=$(prompt_input "Enter the server IP")
        hostname=$(prompt_input "Enter the hostname")
        hostname_prefix=$(prompt_input "Enter the hostname prefix")

        echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

        yum install nano -y
        yum update -y
        yum install almalinux-release -y
        iptables-save > ~/firewall.rules
        systemctl stop firewalld.service
        systemctl disable firewalld.service


        clear

        echo -e "${RED}The Server need a reboot.....${NC}"
        echo -e "${RED}ctrl+c${NC} ${GREEN}To avoid restart${NC}"
        sleep 30
        echo -e "${GREEN}After Reboot run t4s again to continue ${NC}"
        echo -e "${RED}Rebooting ${NC}"
        sleep 3

        reboot now
    2)
        echo -e "${GREEN}You selected Theme4Sell.${NC}"
        sleep 2
        echo -e "${YELLOW}Redirecting...${NC}"
        sleep 2
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        
        ;;
    3)
        echo -e "${GREEN}You selected GB Lic.${NC}"
        echo -e "${GREEN}We are Still working on it${NC}"
        sleep 3
        t4s
        ;;
    4)
        echo -e "${GREEN}You selected WHM and Tweaks installation.${NC}"
        echo -e "${GREEN}We are Still working on it${NC}"
        sleep 3
        t4s
        ;;
    0)
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option! Please select 1-4.${NC}"
        clear
        t4s
        ;;
esac