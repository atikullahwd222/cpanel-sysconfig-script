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

    echo -e "${BLUE}============== RC System Renewal ===============${NC}"
    echo -e " 1) All-in-One Auto Renewal (Beginner Friendly)"
    echo -e " 2) Renew cPanel License"
    echo -e " 3) Renew LiteSpeed Web Server License"
    echo -e " 4) Renew LiteSpeed Load Balancer"
    echo -e " 5) Renew Softaculous License"
    echo -e " 6) Renew JetBackup License"
    echo -e " 7) Renew WHMReseller License"
    echo -e " 8) Renew Imunify360 License"
    echo -e " 9) Renew cPGuard License"
    echo -e "10) Renew Da-Reseller License"
    echo -e "11) Renew OSM License"
    echo -e "12) Renew CXS License"
    echo -e "13) Renew CloudLinux License"
    echo -e "14) Renew SitePad License"
    echo -e "${CYAN}15) RC Menu${NC}"
    echo -e " 0) Exit"
    echo -e "${BLUE}==================================================${NC}"
    read -p "Enter your choice [0-15]: " main_choice
}

# ----------------------------
# Renewal functions
# ----------------------------
renew_cpanel() {
    echo -e "${GREEN}Renewing cPanel...${NC}"
    sleep 2
    RcLicenseCP
    echo -e "${GREEN}cPanel renewal completed!${NC}"
}

renew_litespeed() {
    echo -e "${GREEN}Renewing LiteSpeed...${NC}"
    sleep 2
    RcLicenseLSWS
}

renew_litespeed_lb() {
    echo -e "${GREEN}Renewing LiteSpeed Load Balancer...${NC}"
    RcLSLB
}

renew_softaculous() {
    echo -e "${GREEN}Renewing Softaculous...${NC}"
    RcLicenseSoftaculous
}

renew_jetbackup() {
    echo -e "${GREEN}Renewing JetBackup...${NC}"
    RcLicenseJetBackup
}

renew_whmreseller() {
    echo -e "${GREEN}Renewing WHMReseller...${NC}"
    RcLicenseWHMReseller
}

renew_im360() {
    echo -e "${GREEN}Renewing Imunify360...${NC}"
    wget https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh -O i360deploy.sh
    bash i360deploy.sh
    RcLicenseImunify360
    rm -rf i360deploy.sh
}

renew_cpguard() {
    echo -e "${GREEN}Renewing cPGuard...${NC}"
    RcLicenseCPGuard
}

renew_dareseller() {
    echo -e "${GREEN}Renewing Da-Reseller...${NC}"
    RcLicenseDAReseller
}

renew_osm() {
    echo -e "${GREEN}Renewing OSM...${NC}"
    RcLicenseOSM
}

renew_cxs() {
    echo -e "${GREEN}Renewing CXS...${NC}"
    RcLicenseCXS
}

renew_cloudlinux() {
    echo -e "${GREEN}Renewing CloudLinux...${NC}"
    RcLicenseCLN
}

renew_sitepad() {
    echo -e "${GREEN}Renewing SitePad...${NC}"
    RcLicenseSitepad
}

rc() {
    echo -e "${GREEN}Redirecting to RC Main Page...${NC}"
    sleep 2
    t4s rc
}

goback() {
    echo -e "${GREEN}Redirecting to Main Menue...${NC}"
    sleep 2
    t4s
}

# ----------------------------
# All-in-One Renewal
# ----------------------------
all_in_one_renewal() {
    echo -e "${YELLOW}All-in-One Renewal selected.${NC}"

    # Collect all responses first
    renew_cpanel_choice=$(prompt_input "Renew cPanel?")
    renew_litespeed_choice=$(prompt_input "Renew LiteSpeed?")
    renew_litespeed_lb_choice=$(prompt_input "Renew LiteSpeed Load Balancer?")
    renew_softaculous_choice=$(prompt_input "Renew Softaculous?")
    renew_jetbackup_choice=$(prompt_input "Renew JetBackup?")
    renew_whmreseller_choice=$(prompt_input "Renew WHMReseller?")
    renew_im360_choice=$(prompt_input "Renew Imunify360?")
    renew_cpguard_choice=$(prompt_input "Renew cPGuard?")
    renew_dareseller_choice=$(prompt_input "Renew Da-Reseller?")
    renew_cxs_choice=$(prompt_input "Renew CXS?")
    renew_osm_choice=$(prompt_input "Renew OSM?")
    renew_cloudlinux_choice=$(prompt_input "Renew CloudLinux?")
    renew_sitepad_choice=$(prompt_input "Renew SitePad?")

    # Display summary of choices
    echo -e "${BLUE}================== Summary of Selected Renewals ==================${NC}"
    echo -e "cPanel:              ${renew_cpanel_choice}"
    echo -e "LiteSpeed:           ${renew_litespeed_choice}"
    echo -e "LiteSpeed LB:        ${renew_litespeed_lb_choice}"
    echo -e "Softaculous:         ${renew_softaculous_choice}"
    echo -e "JetBackup:           ${renew_jetbackup_choice}"
    echo -e "WHMReseller:         ${renew_whmreseller_choice}"
    echo -e "Imunify360:          ${renew_im360_choice}"
    echo -e "cPGuard:             ${renew_cpguard_choice}"
    echo -e "Da-Reseller:         ${renew_dareseller_choice}"
    echo -e "OSM:                 ${renew_osm_choice}"
    echo -e "CXS:                 ${renew_cxs_choice}"
    echo -e "CloudLinux:          ${renew_cloudlinux_choice}"
    echo -e "SitePad:             ${renew_sitepad_choice}"
    echo -e "${BLUE}==================================================================${NC}"

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
    [[ "$renew_litespeed_lb_choice" == "y" ]] && renew_litespeed_lb
    [[ "$renew_softaculous_choice" == "y" ]] && renew_softaculous
    [[ "$renew_jetbackup_choice" == "y" ]] && renew_jetbackup
    [[ "$renew_whmreseller_choice" == "y" ]] && renew_whmreseller
    [[ "$renew_im360_choice" == "y" ]] && renew_im360
    [[ "$renew_cpguard_choice" == "y" ]] && renew_cpguard
    [[ "$renew_dareseller_choice" == "y" ]] && renew_dareseller
    [[ "$renew_osm_choice" == "y" ]] && renew_osm
    [[ "$renew_cxs_choice" == "y" ]] && renew_cxs
    [[ "$renew_cloudlinux_choice" == "y" ]] && renew_cloudlinux
    [[ "$renew_sitepad_choice" == "y" ]] && renew_sitepad

    echo -e "${GREEN}All selected renewals completed!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Main execution loop
# ----------------------------
while true; do
    show_main_menu
    case $main_choice in
        1) all_in_one_renewal ;;
        2) renew_cpanel ; read -p "Press Enter to continue...";;
        3) renew_litespeed ; read -p "Press Enter to continue...";;
        4) renew_litespeed_lb ; read -p "Press Enter to continue...";;
        5) renew_softaculous ; read -p "Press Enter to continue...";;
        6) renew_jetbackup ; read -p "Press Enter to continue...";;
        7) renew_whmreseller ; read -p "Press Enter to continue...";;
        8) renew_im360 ; read -p "Press Enter to continue...";;
        9) renew_cpguard ; read -p "Press Enter to continue...";;
        10) renew_dareseller ; read -p "Press Enter to continue...";;
        11) renew_osm ; read -p "Press Enter to continue...";;
        12) renew_cxs ; read -p "Press Enter to continue...";;
        13) renew_cloudlinux ; read -p "Press Enter to continue...";;
        14) renew_sitepad ; read -p "Press Enter to continue...";;
        15) rc ;;
        0) echo "Exiting... Redirecting to t4s rc"; t4s rc;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
done
