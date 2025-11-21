#!/bin/bash

LOCAL_SCRIPT_VERSION="1.0.0"
BASE_URI="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new"
HEADER_URL="$BASE_URI/menuheader.sh"
SCRIPT_URI="$BASE_URI"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Error handler

# Function to center text
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

# Function to display menu
show_menu() {
    clear
    source <(curl -sL $HEADER_URL)

    echo -e "${GREEN}1)${NC} Server Basic Config (Before Installation) ${RED}[Required]${NC}"
    echo -e "${GREEN}2)${NC} RC License Script"
    echo -e "${GREEN}3)${NC} Syslic License Script"
    echo -e "${GREEN}4)${NC} Official Plugin Installation"
    echo -e "${GREEN}5)${NC} Official Plugin Uninstallation"
    echo -e "${GREEN}6)${NC} Tools"
    echo -e "${GREEN}7)${NC} Init t4s Server Fixer"
    echo -e "${GREEN}0)${NC} Exit"
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""
}

# Loop until valid choice
while true; do
    show_menu
    read -p "$(echo -e ${CYAN}Enter your choice [0-7]: ${NC})" choice

    case $choice in
        1)
            echo -e "${YELLOW}You selected: Server Basic Config${NC}"
            echo -e "${YELLOW}Configuring basic server settings...${NC}"
            read -p "Enter the server IP: " server_ip
            read -p "Enter the hostname: " hostname
            read -p "Enter the hostname prefix: " hostname_prefix

            # Validate inputs
            if [[ -z "$server_ip" || -z "$hostname" || -z "$hostname_prefix" ]]; then
                error_exit "Server IP, hostname, and prefix cannot be empty."
            fi

            echo -e "${YELLOW}Updating hosts file...${NC}"
            echo "$server_ip $hostname $hostname_prefix" | tee -a /etc/hosts &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Configuring DNS...${NC}"
            echo "nameserver 8.8.8.8" | tee /etc/resolv.conf &>/dev/null
            echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Installing AlmaLinux release...${NC}"
            yum install almalinux-release -y &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Installing nano...${NC}"
            yum install nano -y &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Setting timezone to Asia/Dhaka...${NC}"
            timedatectl set-timezone Asia/Dhaka &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Updating packages...${NC}"
            yum update -y &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Installing curl and perl...${NC}"
            yum install perl curl -y &>/dev/null &
            spinner $!

            echo -e "${YELLOW}Configuring firewall for WHM...${NC}"
            iptables-save > ~/firewall.rules &>/dev/null
            systemctl stop firewalld.service &>/dev/null
            systemctl disable firewalld.service &>/dev/null &
            spinner $!

            clear
            echo -e "${RED}Server configuration complete. Reboot required.${NC}"
            echo -e "${GREEN}Press Ctrl+C to skip reboot, or wait 30 seconds.${NC}"
            sleep 30
            echo -e "${GREEN}After reboot, run 't4s' to continue.${NC}"
            echo -e "${RED}Rebooting...${NC}"
            reboot now
            ;;
        2)
            echo -e "${YELLOW}You selected: RC License Script${NC}"
            echo -e "${YELLOW}Redirecting to RC License Script...${NC}"
            spinner $!
            sleep 2
            bash <(curl -fsSL $SCRIPT_URI/rc-system/rc.sh)
            ;;
        3)
            echo -e "${YELLOW}You selected: Syslic License Script${NC}"
            spinner $!
            sleep 2
            bash <(curl -fsSL $SCRIPT_URI/rc-system/syslic.sh)
            ;;
        4)
            echo -e "${YELLOW}You selected: Official Plugin Installation${NC}"
            echo -e "${YELLOW}Feature coming soon...${NC}"
            exit 0
            ;;
        5)
            echo -e "${YELLOW}You selected: Official Plugin Uninstallation${NC}"
            echo -e "${YELLOW}Feature coming soon...${NC}"
            exit 0
            ;;
        6)
            echo -e "${YELLOW}Returning to Tools...${NC}"
            sleep 1
            bash <(curl -fsSL $SCRIPT_URI/tools.sh)
            ;;
        7)
            echo -e "${YELLOW}You selected: Init t4s Server Fixer${NC}"
            echo -e "${YELLOW}Installing systemd service for t4s Server Care...${NC}"
            read -p "Proceed to install and start the service now? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                bash <(curl -fsSL $SCRIPT_URI/install-t4s-server-care-service.sh)

                echo -e "${GREEN}t4s Server Care service installed and started!${NC}"
                echo -e "${BLUE}Manage with:${NC} systemctl status t4s-server-care | systemctl restart t4s-server-care"
            else
                echo -e "${YELLOW}Installation cancelled by user.${NC}"
            fi
            sleep 3
            ;;

        0)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please enter a number between 0 and 6.${NC}"
            sleep 2
            ;;
    esac
done
