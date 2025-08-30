#!/bin/bash
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display header
display_header() {
    clear

    source <(curl -sL $HEADER_URL)
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${GREEN}           cPanel & Software Installation Script RC System${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo
}

# Function to prompt user input with color
prompt_input() {
    local prompt="$1"
    echo -e "${YELLOW}${prompt}${NC} ${GREEN}[y/n]${NC}: "
    read -r response
    echo "$response" | tr '[:upper:]' '[:lower:]'
}

# Function to display progress bar
show_progress() {
    local msg="$1"
    echo -ne "${BLUE}[Installing] ${msg} ["
    for ((i=0; i<5; i++)); do
        echo -ne "==="
        sleep 0.3
    done
    echo -e "] ${GREEN}Done${NC}"
}

# Main installation function
main() {
    display_header

    # Collect user inputs
    remove_license=$(prompt_input "Remove existing license?")
    install_cpanel=$(prompt_input "Install cPanel VPS? (Select Carefully)")
    install_litespeed=$(prompt_input "Install and activate LiteSpeed License?")
    install_litespeed_lb=$(prompt_input "Install and activate LiteSpeed Load Balancer?")
    install_softaculous=$(prompt_input "Install Softaculous?")
    install_jetbackup=$(prompt_input "Install JetBackup?")
    install_whmreseller=$(prompt_input "Install WHMReseller?")
    install_im360=$(prompt_input "Install Imunify360? (Select Carefully)")
    install_cpguard=$(prompt_input "Install cPGuard? (Select Carefully)")
    install_dareseller=$(prompt_input "Install Da-Reseller?")
    install_osm=$(prompt_input "Install OSM?")
    install_cxs=$(prompt_input "Install CXS?")
    install_cloudlinux=$(prompt_input "Install CloudLinux?")
    install_sitepad=$(prompt_input "Install SitePad?")
    echo -e "${BLUE}================================================================================${NC}"
    echo

    # Confirmation
    echo -e "${YELLOW}Do you want to proceed with the installation?${NC} ${GREEN}[y/n]${NC}: "
    read proceed
    proceed=$(echo "$proceed" | tr '[:upper:]' '[:lower:]')

    if [[ "$proceed" != "y" ]]; then
        echo -e "${RED}Installation aborted by user.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Starting installation process...${NC}"
    echo

    # Remove existing license
    if [[ "$remove_license" == "y" ]]; then
        show_progress "Removing existing license"
        wget -q -O remover https://mirror.resellercenter.ir/remover && chmod +x remover && ./remover >/dev/null 2>&1
    fi

    # Install cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        show_progress "cPanel VPS"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) cPanel >/dev/null 2>&1
        RcLicenseCP >/dev/null 2>&1
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

    # Install LiteSpeed Load Balancer
    if [[ "$install_litespeed_lb" == "y" ]]; then
        show_progress "LiteSpeed Load Balancer"
        RCUpdate lslb >/dev/null 2>&1
        bash <(curl https://mirror.resellercenter.ir/pre.sh) LSLB >/dev/null 2>&1
        RcLSLB >/dev/null 2>&1
    fi

    # Install LiteSpeed
    if [[ "$install_litespeed" == "y" ]]; then
        show_progress "LiteSpeed"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) liteSpeed >/dev/null 2>&1
        RcLicenseLSWS >/dev/null 2>&1
    fi

    # Install Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        show_progress "Softaculous"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) Softaculous >/dev/null 2>&1
        RcLicenseSoftaculous >/dev/null 2>&1
    fi

    # Install JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        show_progress "JetBackup"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) JetBackup >/dev/null 2>&1
        RcLicenseJetBackup >/dev/null 2>&1
    fi

    # Install WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        show_progress "WHMReseller"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) WHMReseller >/dev/null 2>&1
        RcLicenseWHMReseller >/dev/null 2>&1
    fi

    # Install Imunify360
    if [[ "$install_im360" == "y" ]]; then
        show_progress "Imunify360"
        wget -q https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh && bash i360deploy.sh >/dev/null 2>&1
        bash <(curl https://mirror.resellercenter.ir/pre.sh) Imunify360 >/dev/null 2>&1
        RcLicenseImunify360 >/dev/null 2>&1
    fi

    # Install CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        show_progress "CloudLinux"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) CloudLinux >/dev/null 2>&1
        RcLicenseCLN >/dev/null 2>&1
        t4srcCLN -install >/dev/null 2>&1
    fi

    # Install SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        show_progress "SitePad"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) Sitepad >/dev/null 2>&1
        RcLicenseSitepad >/dev/null 2>&1
    fi

    # Install cPGuard
    if [[ "$install_cpguard" == "y" ]]; then
        show_progress "cPGuard"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) CPGuard >/dev/null 2>&1
        RcLicenseCPGuard >/dev/null 2>&1
    fi

    # Install Da-Reseller
    if [[ "$install_dareseller" == "y" ]]; then
        show_progress "Da-Reseller"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) DAReseller >/dev/null 2>&1
        RcLicenseDAReseller >/dev/null 2>&1
    fi

    # Install OSM
    if [[ "$install_osm" == "y" ]]; then
        show_progress "OSM"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) OSM >/dev/null 2>&1
        RcLicenseOSM >/dev/null 2>&1
    fi

    # Install CXS
    if [[ "$install_cxs" == "y" ]]; then
        show_progress "CXS"
        bash <(curl https://mirror.resellercenter.ir/pre.sh) CXS >/dev/null 2>&1
        RcLicenseCXS >/dev/null 2>&1
    fi

    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${BLUE}================================================================================${NC}"
}

# Execute main function
main