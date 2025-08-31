#!/bin/bash
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"
# Function to center text
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}
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
    source <(curl -sL $HEADER_URL)

    echo -e "${BLUE}============== RC System Installer ===============${NC}"
    echo -e " 1) All-in-One Auto Installer (Beginner Friendly)"
    echo -e " 2) Install/Activate cPanel License"
    echo -e " 3) Install/Activate LiteSpeed Web Server License"
    echo -e " 4) Install/Activate LiteSpeed Load Balancer"
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
    echo -e "${CYAN}15) Renew Licenses${NC}"
    echo -e " 0) Exit"
    echo -e "${BLUE}==================================================${NC}"
    read -p "Enter your choice [0-14]: " main_choice
}

# ----------------------------
# Installation functions
# ----------------------------
install_cpanel() {
    echo -e "${GREEN}Installing cPanel...${NC}"
    sleep 2
    cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest --tier=stable
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) cPanel; RcLicenseCP
    t4s tweak
    /scripts/configure_firewall_for_cpanel
    /usr/local/cpanel/cpsrvd
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -F
    iptables -t mangle -F
    /usr/sbin/iptables -F
    /usr/sbin/iptables -X
    echo -e "${GREEN}cPanel installation completed!${NC}"
}

install_litespeed() {
    echo -e "${GREEN}Installing LiteSpeed...${NC}"
    sleep 2
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) liteSpeed; RcLicenseLSWS
}

install_litespeed_lb() {
    echo -e "${GREEN}Installing LiteSpeed Load Balancer...${NC}"
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) LSLB; RCUpdate lslb
    bash <(curl -s https://mirror.resellercenter.ir/pre.sh) LSLB; RcLSLB
}

install_softaculous() {
    echo -e "${GREEN}Installing Softaculous...${NC}"
    t4s tweak
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) Softaculous; RcLicenseSoftaculous
}

install_jetbackup() {
    echo -e "${GREEN}Installing JetBackup...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) JetBackup; RcLicenseJetBackup
}

# Placeholder for other software, define similar functions
install_whmreseller() {
    echo -e "${GREEN}Installing WHMReseller...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) WHMReseller; RcLicenseWHMReseller
}
install_im360() {
    echo -e "${GREEN}Installing Imunify360...${NC}"
    wget https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh -O i360deploy.sh
    bash i360deploy.sh
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) Imunify360; RcLicenseImunify360
    rm -rf i360deploy.sh
}
install_cpguard() {
    echo -e "${GREEN}Installing cPGuard...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) CPGuard; RcLicenseCPGuard
}
install_dareseller() {
    echo -e "${GREEN}Installing Da-Reseller...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) DAReseller; RcLicenseDAReseller
}
install_csf() {
    echo -e "${GREEN}Installing CSF...${NC}"
    t4s install csf
}

install_osm() {
    echo -e "${GREEN}Installing OSM...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) OSM; RcLicenseOSM
}
install_cxs() {
    echo -e "${GREEN}Installing CXS...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) CXS; RcLicenseCXS
}
install_cloudlinux() {
    echo -e "${GREEN}Installing CloudLinux...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) CloudLinux; RcLicenseCLN
    RcLicenseCLN -install
}
install_sitepad() {
    echo -e "${GREEN}Installing SitePad...${NC}"
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) Sitepad; RcLicenseSitepad
}

renew() {
    echo -e "${GREEN}Redirecting to Renewal Page...${NC}"
    sleep 2
    t4s rc-renew
}

goback() {
    echo -e "${GREEN}Redirecting to Main Menue...${NC}"
    sleep 2
    t4s
}


# ----------------------------
# All-in-One Installer
# ----------------------------
all_in_one_installer() {
    echo -e "${YELLOW}All-in-One Installer selected.${NC}"

    # Collect all responses first
    install_cpanel_choice=$(prompt_input "Install cPanel?")
    install_litespeed_choice=$(prompt_input "Install LiteSpeed?")
    install_litespeed_lb_choice=$(prompt_input "Install LiteSpeed Load Balancer?")
    install_softaculous_choice=$(prompt_input "Install Softaculous?")
    install_jetbackup_choice=$(prompt_input "Install JetBackup?")
    install_whmreseller_choice=$(prompt_input "Install WHMReseller?")
    install_im360_choice=$(prompt_input "Install Imunify360?")
    install_cpguard_choice=$(prompt_input "Install cPGuard?")
    install_dareseller_choice=$(prompt_input "Install Da-Reseller?")
    install_csf_choice=$(prompt_input "Install CSF?")
    install_cxs_choice=$(prompt_input "Install CXS?")
    install_osm_choice=$(prompt_input "Install OSM?")
    install_cloudlinux_choice=$(prompt_input "Install CloudLinux?")
    install_sitepad_choice=$(prompt_input "Install SitePad?")

    # Display summary of choices
    echo -e "${BLUE}================== Summary of Selected Installations ==================${NC}"
    echo -e "cPanel:              ${install_cpanel_choice}"
    echo -e "LiteSpeed:           ${install_litespeed_choice}"
    echo -e "LiteSpeed LB:        ${install_litespeed_lb_choice}"
    echo -e "Softaculous:         ${install_softaculous_choice}"
    echo -e "JetBackup:           ${install_jetbackup_choice}"
    echo -e "WHMReseller:         ${install_whmreseller_choice}"
    echo -e "Imunify360:          ${install_im360_choice}"
    echo -e "cPGuard:             ${install_cpguard_choice}"
    echo -e "Da-Reseller:         ${install_dareseller_choice}"
    echo -e "CSF:                 ${install_csf_choice}"
    echo -e "OSM:                 ${install_osm_choice}"
    echo -e "CXS:                 ${install_cxs_choice}"
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
    [[ "$install_litespeed_lb_choice" == "y" ]] && install_litespeed_lb
    [[ "$install_softaculous_choice" == "y" ]] && install_softaculous
    [[ "$install_jetbackup_choice" == "y" ]] && install_jetbackup
    [[ "$install_whmreseller_choice" == "y" ]] && install_whmreseller
    [[ "$install_im360_choice" == "y" ]] && install_im360
    [[ "$install_cpguard_choice" == "y" ]] && install_cpguard
    [[ "$install_dareseller_choice" == "y" ]] && install_dareseller
    [[ "$install_csf_choice" == "y" ]] && install_csf
    [[ "$install_osm_choice" == "y" ]] && install_osm
    [[ "$install_cxs_choice" == "y" ]] && install_cxs
    [[ "$install_cloudlinux_choice" == "y" ]] && install_cloudlinux
    [[ "$install_sitepad_choice" == "y" ]] && install_sitepad

    echo -e "${GREEN}All selected installations completed!${NC}"
    read -p "Press Enter to continue..."
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
        7) install_whmreseller ;;
        8) install_im360 ;;
        9) install_cpguard ;;
        10) install_dareseller ;;
        11) install_osm ;;
        12) install_cxs ;;
        13) install_cloudlinux ;;
        14) install_sitepad ;;
        14) install_sitepad ;;
        15) renew ;;
        0) goback ;;
        *) echo -e "${RED}Invalid option!${NC}" ;;
    esac
done
    read -p "Press Enter to continue..."
