#!/bin/bash

# ----------------------------
# Constants and Colors
# ----------------------------
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ----------------------------
# Display Header
# ----------------------------
display_header() {
    clear
    echo -e "${BLUE}================================================================================${NC}"
    if curl -sL "$HEADER_URL" | bash; then
        echo -e "${GREEN}Loaded custom header successfully${NC}"
    else
        echo -e "${RED}Failed to load custom header, using default${NC}"
        echo -e "${GREEN}           cPanel & Software Installation Script - RC System${NC}"
    fi
    echo -e "${BLUE}================================================================================${NC}"
    echo
}

# ----------------------------
# Show Interactive Menu
# ----------------------------
show_menu() {
    printf "${BOLD}Select an installation option:${NC}\n"
    printf "${BLUE} 1)${NC} All-in-One Auto Installer ${YELLOW}(Beginner Friendly)${NC}\n"
    printf "${BLUE} 2)${NC} Install/Activate cPanel License\n"
    printf "${BLUE} 3)${NC} Install/Activate LiteSpeed Web Server License\n"
    printf "${BLUE} 4)${NC} Install/Activate LiteSpeed Load Balancer ${RED}(DDoS Protection)${NC} License\n"
    printf "${BLUE} 5)${NC} Install/Activate Softaculous License\n"
    printf "${BLUE} 6)${NC} Install/Activate JetBackup License\n"
    printf "${BLUE} 7)${NC} Install/Activate WHMReseller License\n"
    printf "${BLUE} 8)${NC} Install/Activate Imunify360 License\n"
    printf "${BLUE} 9)${NC} Install/Activate cPGuard License\n"
    printf "${BLUE}10)${NC} Install/Activate Da-Reseller License\n"
    printf "${BLUE}11)${NC} Install/Activate OSM License\n"
    printf "${BLUE}12)${NC} Install/Activate CXS License\n"
    printf "${BLUE}13)${NC} Install/Activate CloudLinux License\n"
    printf "${BLUE}14)${NC} Install/Activate SitePad License\n\n"

    printf "${RED} 0) Go Back${NC}\n"
    printf "=============--- BH System V$T4S_VERSION | Theme4Sell ---=============\n"
    read -p "Enter your choice [0-14]: " choice
}

# ----------------------------
# Display Progress
# ----------------------------
show_progress() {
    local msg="$1"
    printf "${BLUE}%-50s [" "$msg"
    for ((i=0;i<5;i++)); do
        printf "==="; sleep 0.3
    done
    echo -e "] ${GREEN}Done${NC}"
}

# ----------------------------
# Execute Command and Check
# ----------------------------
check_command() {
    local cmd="$1"
    local msg="$2"
    if eval "$cmd"; then
        echo -e "${GREEN}$msg completed successfully${NC}"
    else
        echo -e "${RED}Error: $msg failed${NC}"
        exit 1
    fi
}

# ----------------------------
# Main Installation Function
# ----------------------------
main() {
    display_header
    show_menu

    read -p "$(echo -e ${YELLOW}Enter your choices separated by space: ${NC})" selections

    echo "===================================================================================================="
    remove_license=$(prompt_input "Do you want to remove the existing license? (y/n)")
    install_cpanel=$(prompt_input "Do you want to install cPanel VPS ${YELLOW}(Select Carefully)${NC}? (y/n)")
    # install_dedicated=$(prompt_input "Do you want to install Cpanel Dedicated ${YELLOW}(Select Carefully)${NC}? (y/n)")
    install_litespeed=$(prompt_input "Do you want to install and activate LiteSpeed License? (y/n)")
    install_litespeed_lb=$(prompt_input "Do you want to install and activate LiteSpeed Load Balancer? (y/n)")
    install_softaculous=$(prompt_input "Do you want to install Softaculous? (y/n)")
    install_jetbackup=$(prompt_input "Do you want to install JetBackup? (y/n)")
    install_whmreseller=$(prompt_input "Do you want to install WHMReseller? (y/n)")
    install_im360=$(prompt_input "Do you want to install Imunify360 ${YELLOW}(Select Carefully)${NC}? (y/n)")
    install_cpguard=$(prompt_input "Do you want to install cPGuard ${YELLOW}(Select Carefully)${NC}? (y/n)")
    install_dareseller=$(prompt_input "Do you want to install Da-Reseller? (y/n)")
    install_osm=$(prompt_input "Do you want to install OSM? (y/n)")
    install_cxs=$(prompt_input "Do you want to install CXS? (y/n)")
    install_cloudlinux=$(prompt_input "Do you want to install CloudLinux? (y/n)")
    install_sitepad=$(prompt_input "Do you want to install SitePad? (y/n)")
    echo "===================================================================================================="

    :


    echo "Do you want to proceed with the installation? (y/n)"
    read proceed


    if [[ "$remove_license" == "y" ]]; then
        wget -q -O remover https://mirror.resellercenter.ir/remover && chmod +x remover && ./remover >/dev/null 2>&1
    fi
    # Installing cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) cPanel >/dev/null 2>&1; RcLicenseCP >/dev/null 2>&1
        RcLicenseCP -fleetssl >/dev/null 2>&1
        /scripts/configure_firewall_for_cpanel >/dev/null 2>&1
        /usr/local/cpanel/cpsrvd >/dev/null 2>&1
        iptables -P INPUT ACCEPT >/dev/null 2>&1
        iptables -P FORWARD ACCEPT >/dev/null 2>&1
        iptables -P OUTPUT ACCEPT >/dev/null 2>&1
        iptables -t nat -F >/dev/null 2>&1
        iptables -t mangle -F >/dev/null 2>&1
        /usr/sbin/iptables -F >/dev/null 2>&1
        /usr/sbin/iptables -X >/dev/null 2>&1
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) &>/dev/null
    fi


    if [[ "$install_litespeed_lb" == "y" ]]; then
        RCUpdate lslb >/dev/null 2>&1
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) LSLB >/dev/null 2>&1; RcLSLB >/dev/null 2>&1
    fi

    # Installing and enabling LiteSpeedX
    if [[ "$install_litespeed" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) liteSpeed >/dev/null 2>&1; RcLicenseLSWS >/dev/null 2>&1
    fi

    # Installing and enabling Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Softaculous >/dev/null 2>&1; RcLicenseSoftaculous >/dev/null 2>&1
    fi

    # Installing and enabling JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) JetBackup >/dev/null 2>&1; RcLicenseJetBackup >/dev/null 2>&1
    fi

    # Installing and enabling WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) WHMReseller >/dev/null 2>&1; RcLicenseWHMReseller >/dev/null 2>&1
    fi

    # Installing and enabling Imunify360
    if [[ "$install_im360" == "y" ]]; then
        wget -q https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh && bash i360deploy.sh >/dev/null 2>&1
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Imunify360 >/dev/null 2>&1; RcLicenseImunify360 >/dev/null 2>&1
    fi

    # Installing and enabling CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CloudLinux >/dev/null 2>&1; RcLicenseCLN >/dev/null 2>&1
        t4srcCLN -install >/dev/null 2>&1
    fi

    # Installing and enabling SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Sitepad >/dev/null 2>&1; RcLicenseSitepad >/dev/null 2>&1
    fi

    if [[ "$install_cpguard" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CPGuard >/dev/null 2>&1; RcLicenseCPGuard >/dev/null 2>&1
    fi

    if [[ "$install_dareseller" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) DAReseller >/dev/null 2>&1; RcLicenseDAReseller >/dev/null 2>&1
    fi

    if [[ "$install_osm" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) OSM >/dev/null 2>&1; RcLicenseOSM >/dev/null 2>&1
    fi

    if [[ "$install_cxs" == "y" ]]; then
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CXS >/dev/null 2>&1; RcLicenseCXS >/dev/null 2>&1
    fi

    echo -e "${GREEN}All selected tasks completed!${NC}"
}

# ----------------------------
# Trap errors
# ----------------------------
trap 'echo -e "${RED}An error occurred. Exiting...${NC}"; exit 1' ERR

# ----------------------------
# Run the main function
# ----------------------------
main
