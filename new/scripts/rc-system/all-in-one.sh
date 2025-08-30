#!/bin/bash
# Constants
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"

# Function to display header
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

# Function to prompt user input with color
prompt_input() {
    local prompt="$1"
    printf "${YELLOW}%-50s${NC} ${GREEN}[y/n]: ${NC}" "$prompt"
    read -r response
    echo "$response" | tr '[:upper:]' '[:lower:]'
}

# Function to display progress bar
show_progress() {
    local msg="$1"
    printf "${BLUE}%-50s [" "$msg"
    for ((i=0; i<5; i++)); do
        printf "==="
        sleep 0.5 # Slower animation for visibility
    done
    echo -e "] ${GREEN}Done${NC}"
}

# Function to check command success
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

# Main installation function
main() {
    display_header

    # Collect user inputs
    echo -e "${BLUE}Select software to install:${NC}"
    echo
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

    # Display summary of selections
    echo -e "${BLUE}Installation Summary:${NC}"
    echo -e "${YELLOW}Remove License: ${GREEN}$remove_license${NC}"
    echo -e "${YELLOW}cPanel VPS: ${GREEN}$install_cpanel${NC}"
    echo -e "${YELLOW}LiteSpeed: ${GREEN}$install_litespeed${NC}"
    echo -e "${YELLOW}LiteSpeed Load Balancer: ${GREEN}$install_litespeed_lb${NC}"
    echo -e "${YELLOW}Softaculous: ${GREEN}$install_softaculous${NC}"
    echo -e "${YELLOW}JetBackup: ${GREEN}$install_jetbackup${NC}"
    echo -e "${YELLOW}WHMReseller: ${GREEN}$install_whmreseller${NC}"
    echo -e "${YELLOW}Imunify360: ${GREEN}$install_im360${NC}"
    echo -e "${YELLOW}cPGuard: ${GREEN}$install_cpguard${NC}"
    echo -e "${YELLOW}Da-Reseller: ${GREEN}$install_dareseller${NC}"
    echo -e "${YELLOW}OSM: ${GREEN}$install_osm${NC}"
    echo -e "${YELLOW}CXS: ${GREEN}$install_cxs${NC}"
    echo -e "${YELLOW}CloudLinux: ${GREEN}$install_cloudlinux${NC}"
    echo -e "${YELLOW}SitePad: ${GREEN}$install_sitepad${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    echo

    # Confirmation
    printf "${YELLOW}Proceed with the installation?${NC} ${GREEN}[y/n]: ${NC}"
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
        check_command "wget -q -O remover https://mirror.resellercenter.ir/remover && chmod +x remover && ./remover" "License removal"
    fi

    # Install cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        show_progress "cPanel VPS"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) cPanel && RcLicenseCP && RcLicenseCP -fleetssl && /scripts/configure_firewall_for_cpanel && /usr/local/cpanel/cpsrvd && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT && iptables -t nat -F && iptables -t mangle -F && /usr/sbin/iptables -F && /usr/sbin/iptables -X && bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh)" "cPanel installation"
    fi

    # Install LiteSpeed Load Balancer
    if [[ "$install_litespeed_lb" == "y" ]]; then
        show_progress "LiteSpeed Load Balancer"
        check_command "RCUpdate lslb && bash <(curl -s https://mirror.resellercenter.ir/pre.sh) LSLB && RcLSLB" "LiteSpeed Load Balancer installation"
    fi

    # Install LiteSpeed
    if [[ "$install_litespeed" == "y" ]]; then
        show_progress "LiteSpeed"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) liteSpeed && RcLicenseLSWS" "LiteSpeed installation"
    fi

    # Install Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        show_progress "Softaculous"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Softaculous && RcLicenseSoftaculous" "Softaculous installation"
    fi

    # Install JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        show_progress "JetBackup"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) JetBackup && RcLicenseJetBackup" "JetBackup installation"
    fi

    # Install WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        show_progress "WHMReseller"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) WHMReseller && RcLicenseWHMReseller" "WHMReseller installation"
    fi

    # Install Imunify360
    if [[ "$install_im360" == "y" ]]; then
        show_progress "Imunify360"
        check_command "wget -q https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh && bash i360deploy.sh && bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Imunify360 && RcLicenseImunify360" "Imunify360 installation"
    fi

    # Install CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        show_progress "CloudLinux"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CloudLinux && RcLicenseCLN && t4srcCLN -install" "CloudLinux installation"
    fi

    # Install SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        show_progress "SitePad"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Sitepad && RcLicenseSitepad" "SitePad installation"
    fi

    # Install cPGuard
    if [[ "$install_cpguard" == "y" ]]; then
        show_progress "cPGuard"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CPGuard && RcLicenseCPGuard" "cPGuard installation"
    fi

    # Install Da-Reseller
    if [[ "$install_dareseller" == "y" ]]; then
        show_progress "Da-Reseller"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) DAReseller && RcLicenseDAReseller" "Da-Reseller installation"
    fi

    # Install OSM
    if [[ "$install_osm" == "y" ]]; then
        show_progress "OSM"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) OSM && RcLicenseOSM" "OSM installation"
    fi

    # Install CXS
    if [[ "$install_cxs" == "y" ]]; then
        show_progress "CXS"
        check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CXS && RcLicenseCXS" "CXS installation"
    fi

    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${BLUE}================================================================================${NC}"
}

# Trap errors and display message
trap 'echo -e "${RED}An error occurred. Exiting...${NC}"; exit 1' ERR

# Execute main function
main