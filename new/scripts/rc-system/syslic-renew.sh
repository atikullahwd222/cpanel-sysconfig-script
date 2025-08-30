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

    echo -e "${BLUE}================ syslic-renewal Manager ================${NC}"
    echo -e " 1) Init the System ${RED}! Important !${NC}"
    echo -e " 2) All-in-One Auto Renewal (Beginner Friendly)"
    echo -e " 3) Renew cPanel License"
    echo -e " 4) Renew LiteSpeed Web Server License"
    echo -e " 5) Renew Softaculous License"
    echo -e " 6) Renew JetBackup License"
    echo -e " 7) Renew WHMReseller License"
    echo -e " 8) Renew Imunify360 License"
    echo -e " 9) Renew CloudLinux License"
    echo -e "10) Renew SitePad License"
    echo -e "${CYAN}11) Syslic Menue${NC}"
    echo -e " 0) Exit"
    echo -e "${BLUE}========================================================${NC}"
    read -p "Enter your choice [0-10]: " main_choice
}

# ----------------------------
# Renewal functions
# ----------------------------
init_system() {
    echo -e "${GREEN}Initializing system...${NC}"
    sleep 2
    curl -sL https://repo.magicbyte.pw/setup.sh | sudo bash -
    echo -e "${GREEN}System initialization completed!${NC}"
}

renew_cpanel() {
    echo -e "${GREEN}Renewing cPanel License...${NC}"
    sysconfig cpanel enable
    echo -e "${GREEN}cPanel License renewed!${NC}"
}

renew_litespeed() {
    echo -e "${GREEN}Renewing LiteSpeed License...${NC}"
    sysconfig litespeedx enable
    echo -e "${GREEN}LiteSpeed License renewed!${NC}"
}

renew_softaculous() {
    echo -e "${GREEN}Renewing Softaculous License...${NC}"
    sysconfig softaculous enable
    echo -e "${GREEN}Softaculous License renewed!${NC}"
}

renew_jetbackup() {
    echo -e "${GREEN}Renewing JetBackup License...${NC}"
    sysconfig jetbackup enable
    echo -e "${GREEN}JetBackup License renewed!${NC}"
}

renew_whmreseller() {
    echo -e "${GREEN}Renewing WHMReseller License...${NC}"
    sysconfig whmreseller enable
    echo -e "${GREEN}WHMReseller License renewed!${NC}"
}

renew_im360() {
    echo -e "${GREEN}Renewing Imunify360 License...${NC}"
    sysconfig im360 enable
    echo -e "${GREEN}Imunify360 License renewed!${NC}"
}

renew_cloudlinux() {
    echo -e "${GREEN}Renewing CloudLinux License...${NC}"
    sysconfig cloudlinux enable
    echo -e "${GREEN}CloudLinux License renewed!${NC}"
}

renew_sitepad() {
    echo -e "${GREEN}Renewing SitePad License...${NC}"
    sysconfig sitepad enable
    echo -e "${GREEN}SitePad License renewed!${NC}"
}

syslic() {
    echo -e "${GREEN}Redirecting to Renewal Page...${NC}"
    sleep 2
    t4s syslic
}

goback() {
    echo -e "${GREEN}Redirecting to Main Menue...${NC}"
    sleep 2
    t4s
}

# ----------------------------
# All-in-One Renewal (Init First)
# ----------------------------
all_in_one_renewal() {
    echo -e "${YELLOW}All-in-One Renewal selected.${NC}"

    # Always run init first
    init_system

    # Collect all responses first
    renew_cpanel_choice=$(prompt_input "Renew cPanel?")
    renew_litespeed_choice=$(prompt_input "Renew LiteSpeed?")
    renew_softaculous_choice=$(prompt_input "Renew Softaculous?")
    renew_jetbackup_choice=$(prompt_input "Renew JetBackup?")
    renew_whmreseller_choice=$(prompt_input "Renew WHMReseller?")
    renew_im360_choice=$(prompt_input "Renew Imunify360?")
    renew_csf_choice=$(prompt_input "Renew CSF?")
    renew_cloudlinux_choice=$(prompt_input "Renew CloudLinux?")
    renew_sitepad_choice=$(prompt_input "Renew SitePad?")

    # Display summary of choices
    echo -e "${BLUE}================== Summary of Selected Renewals ==================${NC}"
    echo -e "cPanel:              ${renew_cpanel_choice}"
    echo -e "LiteSpeed:           ${renew_litespeed_choice}"
    echo -e "Softaculous:         ${renew_softaculous_choice}"
    echo -e "JetBackup:           ${renew_jetbackup_choice}"
    echo -e "WHMReseller:         ${renew_whmreseller_choice}"
    echo -e "Imunify360:          ${renew_im360_choice}"
    echo -e "CSF:                 ${renew_csf_choice}"
    echo -e "CloudLinux:          ${renew_cloudlinux_choice}"
    echo -e "SitePad:             ${renew_sitepad_choice}"
    echo -e "${BLUE}=================================================================${NC}"

    # Double confirmation
    confirm=$(prompt_input "Are you sure you want to proceed with all selected renewals?")
    if [[ "$confirm" != "y" ]]; then
        echo -e "${RED}Renewal aborted by user.${NC}"
        return
    fi

    echo -e "${BLUE}Starting selected renewals...${NC}"

    # Run renewals sequentially
    [[ "$renew_cpanel_choice" == "y" ]] && renew_cpanel
    [[ "$renew_litespeed_choice" == "y" ]] && renew_litespeed
    [[ "$renew_softaculous_choice" == "y" ]] && renew_softaculous
    [[ "$renew_jetbackup_choice" == "y" ]] && renew_jetbackup
    [[ "$renew_whmreseller_choice" == "y" ]] && renew_whmreseller
    [[ "$renew_im360_choice" == "y" ]] && renew_im360
    [[ "$renew_csf_choice" == "y" ]] && renew_csf
    [[ "$renew_cloudlinux_choice" == "y" ]] && renew_cloudlinux
    [[ "$renew_sitepad_choice" == "y" ]] && renew_sitepad

    echo -e "${GREEN}All selected renewals completed!${NC}"
}

# ----------------------------
# Main execution loop
# ----------------------------
while true; do
    show_main_menu
    case $main_choice in
        1) init_system ;;
        2) all_in_one_renewal ;;
        3) renew_cpanel ;;
        4) renew_litespeed ;;
        5) renew_softaculous ;;
        6) renew_jetbackup ;;
        7) renew_whmreseller ;;
        8) renew_im360 ;;
        9) renew_cloudlinux ;;
        10) renew_sitepad ;;
        11) syslic ;;
        0) goback ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
done
