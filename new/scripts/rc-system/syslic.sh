#!/bin/bash
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"

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
# Function to center text
# ----------------------------
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

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
    source <(curl -sL $HEADER_URL)

    echo -e "${BLUE}================ Syslic Installer ================${NC}"
    echo -e " 1) Init the System ${RED}! Important !${NC}"
    echo -e " 2) All-in-One Auto Installer (Beginner Friendly)"
    echo -e " 3) Install/Activate cPanel License"
    echo -e " 4) Install/Activate LiteSpeed Web Server License"
    echo -e " 5) Install/Activate Softaculous License"
    echo -e " 6) Install/Activate JetBackup License"
    echo -e " 7) Install/Activate WHMReseller License"
    echo -e " 8) Install/Activate Imunify360 License"
    echo -e " 9) Install/Activate CloudLinux License"
    echo -e "10) Install/Activate SitePad License"
    echo -e "${CYAN}11) Renew Licenses${NC}"
    echo -e " 0) Exit"
    echo -e "${BLUE}==================================================${NC}"
    read -p "Enter your choice [0-10]: " main_choice
}

# ----------------------------
# Installation functions
# ----------------------------
init_system() {
    echo -e "${GREEN}Initializing system...${NC}"
    sleep 2
    curl -sL https://repo.magicbyte.pw/setup.sh | sudo bash -
    echo -e "${GREEN}System initialization completed!${NC}"
}

install_cpanel() {
    echo -e "${GREEN}Installing cPanel...${NC}"
    sleep 2
    cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest --tier=stable
    sysconfig cpanel update
    sysconfig cpanel enable
    t4s tweak
    echo -e "${GREEN}cPanel installation completed!${NC}"
}

install_litespeed() {
    echo -e "${GREEN}Installing LiteSpeed...${NC}"
    sysconfig litespeedx install
    sysconfig litespeedx enable
}

install_softaculous() {
    echo -e "${GREEN}Installing Softaculous...${NC}"
    t4s tweak
    sysconfig softaculous install
    sysconfig softaculous enable
}

install_jetbackup() {
    echo -e "${GREEN}Installing JetBackup...${NC}"
    sysconfig jetbackup install
    sysconfig jetbackup enable
}

install_whmreseller() {
    echo -e "${GREEN}Installing WHMReseller...${NC}"
    sysconfig whmreseller install
    sysconfig whmreseller enable
}

install_im360() {
    echo -e "${GREEN}Installing Imunify360...${NC}"
    sysconfig im360 install
    sysconfig im360 enable
}

install_csf() {
    echo -e "${GREEN}Installing CSF...${NC}"
    t4s install csf
}

install_cloudlinux() {
    echo -e "${GREEN}Installing CloudLinux...${NC}"
    sysconfig cloudlinux install
    sysconfig cloudlinux enable
}

install_sitepad() {
    echo -e "${GREEN}Installing SitePad...${NC}"
    sysconfig sitepad install
    sysconfig sitepad enable
}

renew() {
    echo -e "${GREEN}Redirecting to Renewal Page...${NC}"
    sleep 2
    t4s syslic-renew
}

goback() {
    echo -e "${GREEN}Redirecting to Main Menue...${NC}"
    sleep 2
    t4s
}

# ----------------------------
# All-in-One Installer (Init First)
# ----------------------------
all_in_one_installer() {
    echo -e "${YELLOW}All-in-One Installer selected.${NC}"

    # Always run init first
    init_system

    # Collect all responses first
    install_cpanel_choice=$(prompt_input "Install cPanel?")
    install_litespeed_choice=$(prompt_input "Install LiteSpeed?")
    install_softaculous_choice=$(prompt_input "Install Softaculous?")
    install_jetbackup_choice=$(prompt_input "Install JetBackup?")
    install_whmreseller_choice=$(prompt_input "Install WHMReseller?")
    install_im360_choice=$(prompt_input "Install Imunify360?")
    install_csf_choice=$(prompt_input "Install CSF?")
    install_cloudlinux_choice=$(prompt_input "Install CloudLinux?")
    install_sitepad_choice=$(prompt_input "Install SitePad?")

    # Display summary of choices
    echo -e "${BLUE}================== Summary of Selected Installations ==================${NC}"
    echo -e "cPanel:              ${install_cpanel_choice}"
    echo -e "LiteSpeed:           ${install_litespeed_choice}"
    echo -e "Softaculous:         ${install_softaculous_choice}"
    echo -e "JetBackup:           ${install_jetbackup_choice}"
    echo -e "WHMReseller:         ${install_whmreseller_choice}"
    echo -e "Imunify360:          ${install_im360_choice}"
    echo -e "CSF:                 ${install_csf_choice}"
    echo -e "CloudLinux:          ${install_cloudlinux_choice}"
    echo -e "SitePad:             ${install_sitepad_choice}"
    echo -e "${BLUE}======================================================================${NC}"

    # Double confirmation
    confirm=$(prompt_input "Are you sure you want to proceed with all selected installations?")
    if [[ "$confirm" != "y" ]]; then
        echo -e "${RED}Installation aborted by user.${NC}"
        return
    fi

    echo -e "${BLUE}Starting selected installations...${NC}"

    # Run installations sequentially
    [[ "$install_cpanel_choice" == "y" ]] && install_cpanel
    [[ "$install_litespeed_choice" == "y" ]] && install_litespeed
    [[ "$install_softaculous_choice" == "y" ]] && install_softaculous
    [[ "$install_jetbackup_choice" == "y" ]] && install_jetbackup
    [[ "$install_whmreseller_choice" == "y" ]] && install_whmreseller
    [[ "$install_im360_choice" == "y" ]] && install_im360
    [[ "$install_csf_choice" == "y" ]] && install_csf
    [[ "$install_cloudlinux_choice" == "y" ]] && install_cloudlinux
    [[ "$install_sitepad_choice" == "y" ]] && install_sitepad

    echo -e "${GREEN}All selected installations completed!${NC}"
}

# ----------------------------
# Main execution loop
# ----------------------------
while true; do
    show_main_menu
    case $main_choice in
        1) init_system ;;
        2) all_in_one_installer ;;
        3) install_cpanel ;;
        4) install_litespeed ;;
        5) install_softaculous ;;
        6) install_jetbackup ;;
        7) install_whmreseller ;;
        8) install_im360 ;;
        9) install_cloudlinux ;;
        10) install_sitepad ;;
        11) renew ;;
        0) goback ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
    read -p "Press Enter to return to main menu..."
done
