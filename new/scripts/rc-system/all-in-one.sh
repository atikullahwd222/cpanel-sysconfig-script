#!/bin/bash

# ----------------------------
# Constants & Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ----------------------------
# Function to prompt user input
# ----------------------------
prompt_input() {
    local prompt="$1"
    read -p "$prompt [y/n]: " response
    echo "$response" | tr '[:upper:]' '[:lower:]'
}

# ----------------------------
# Display main menu
# ----------------------------
show_main_menu() {
    clear
    echo -e "${BLUE}==================== RC System Installer ====================${NC}"
    echo -e " 1) All-in-One Auto Installer (Beginner Friendly)"
    echo -e " 2) Install/Activate cPanel License"
    echo -e " 3) Install/Activate LiteSpeed Web Server License"
    echo -e " 4) Install/Activate LiteSpeed Load Balancer (DDoS Protection) License"
    echo -e " 5) Install/Activate Softaculous License"
    echo -e " 6) Install/Activate JetBackup License"
    echo -e " 7) Install/Activate WHMReseller License"
    echo -e " 8) Install/Activate Imunify360 License"
    echo -e " 9) Install/Activate cPGuard License"
    echo -e "10) Install/Activate Da-Reseller License"
    echo -e "11) Install/Activate OSM License"
    echo -e "12) Install/Activate CXS License"
    echo -e "13) Install/Activate CloudLinux License"
    echo -e "14) Install/Activate SitePad License"
    echo -e " 0) Exit"
    echo -e "${BLUE}============================================================${NC}"
    read -p "Enter your choice [0-14]: " main_choice
}

# ----------------------------
# Installation functions
# ----------------------------
install_cpanel() {
    echo -e "${GREEN}Installing cPanel...${NC}"
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) cPanel >/dev/null 2>&1
    RcLicenseCP >/dev/null 2>&1
}

install_litespeed() {
    echo -e "${GREEN}Installing LiteSpeed...${NC}"
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) liteSpeed >/dev/null 2>&1
    RcLicenseLSWS >/dev/null 2>&1
}

install_litespeed_lb() {
    echo -e "${GREEN}Installing LiteSpeed Load Balancer...${NC}"
    RCUpdate lslb >/dev/null 2>&1
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) LSLB >/dev/null 2>&1
    RcLSLB >/dev/null 2>&1
}

install_softaculous() {
    echo -e "${GREEN}Installing Softaculous...${NC}"
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Softaculous >/dev/null 2>&1
    RcLicenseSoftaculous >/dev/null 2>&1
}

install_jetbackup() {
    echo -e "${GREEN}Installing JetBackup...${NC}"
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) JetBackup >/dev/null 2>&1
    RcLicenseJetBackup >/dev/null 2>&1
}

# ... define other install_* functions similarly ...

# ----------------------------
# All-in-One Installer
# ----------------------------
all_in_one_installer() {
    echo -e "${YELLOW}All-in-One Installer selected.${NC}"
    [[ $(prompt_input "Install cPanel?") == "y" ]] && install_cpanel
    [[ $(prompt_input "Install LiteSpeed?") == "y" ]] && install_litespeed
    [[ $(prompt_input "Install LiteSpeed Load Balancer?") == "y" ]] && install_litespeed_lb
    [[ $(prompt_input "Install Softaculous?") == "y" ]] && install_softaculous
    [[ $(prompt_input "Install JetBackup?") == "y" ]] && install_jetbackup
    # ... repeat for other software ...
    echo -e "${GREEN}All selected installations completed!${NC}"
}

# ----------------------------
# Main execution loop
# ----------------------------
while true; do
    show_main_menu
    case $main_choice in
        1) all_in_one_installer ;;
        2) install_cpanel ;;
        3) install_litespeed ;;
        4) install_litespeed_lb ;;
        5) install_softaculous ;;
        6) install_jetbackup ;;
        7) echo "Installing WHMReseller..." ;; # placeholder
        8) echo "Installing Imunify360..." ;;
        9) echo "Installing cPGuard..." ;;
        10) echo "Installing Da-Reseller..." ;;
        11) echo "Installing OSM..." ;;
        12) echo "Installing CXS..." ;;
        13) echo "Installing CloudLinux..." ;;
        14) echo "Installing SitePad..." ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    read -p "Press Enter to return to main menu..."
done
