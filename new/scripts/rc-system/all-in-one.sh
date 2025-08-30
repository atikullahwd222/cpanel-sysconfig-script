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
    echo -e "${CYAN}Select software to install (enter numbers separated by space):${NC}"
    echo -e "${GREEN}1)${NC} Remove existing license"
    echo -e "${GREEN}2)${NC} Install cPanel VPS"
    echo -e "${GREEN}3)${NC} Install LiteSpeed License"
    echo -e "${GREEN}4)${NC} Install LiteSpeed Load Balancer"
    echo -e "${GREEN}5)${NC} Install Softaculous"
    echo -e "${GREEN}6)${NC} Install JetBackup"
    echo -e "${GREEN}7)${NC} Install WHMReseller"
    echo -e "${GREEN}8)${NC} Install Imunify360"
    echo -e "${GREEN}9)${NC} Install cPGuard"
    echo -e "${GREEN}10)${NC} Install Da-Reseller"
    echo -e "${GREEN}11)${NC} Install OSM"
    echo -e "${GREEN}12)${NC} Install CXS"
    echo -e "${GREEN}13)${NC} Install CloudLinux"
    echo -e "${GREEN}14)${NC} Install SitePad"
    echo -e "${GREEN}0)${NC} Exit"
    echo
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

    for choice in $selections; do
        case $choice in
            1)
                show_progress "Removing existing license"
                check_command "wget -q -O remover https://mirror.resellercenter.ir/remover && chmod +x remover && ./remover" "License removal"
                ;;
            2)
                show_progress "Installing cPanel VPS"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) cPanel && RcLicenseCP && RcLicenseCP -fleetssl && /scripts/configure_firewall_for_cpanel" "cPanel installation"
                ;;
            3)
                show_progress "Installing LiteSpeed License"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) liteSpeed && RcLicenseLSWS" "LiteSpeed installation"
                ;;
            4)
                show_progress "Installing LiteSpeed Load Balancer"
                check_command "RCUpdate lslb && bash <(curl -s https://mirror.resellercenter.ir/pre.sh) LSLB && RcLSLB" "LiteSpeed Load Balancer installation"
                ;;
            5)
                show_progress "Installing Softaculous"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Softaculous && RcLicenseSoftaculous" "Softaculous installation"
                ;;
            6)
                show_progress "Installing JetBackup"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) JetBackup && RcLicenseJetBackup" "JetBackup installation"
                ;;
            7)
                show_progress "Installing WHMReseller"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) WHMReseller && RcLicenseWHMReseller" "WHMReseller installation"
                ;;
            8)
                show_progress "Installing Imunify360"
                check_command "wget -q https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh && bash i360deploy.sh && bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Imunify360 && RcLicenseImunify360" "Imunify360 installation"
                ;;
            9)
                show_progress "Installing cPGuard"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CPGuard && RcLicenseCPGuard" "cPGuard installation"
                ;;
            10)
                show_progress "Installing Da-Reseller"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) DAReseller && RcLicenseDAReseller" "Da-Reseller installation"
                ;;
            11)
                show_progress "Installing OSM"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) OSM && RcLicenseOSM" "OSM installation"
                ;;
            12)
                show_progress "Installing CXS"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CXS && RcLicenseCXS" "CXS installation"
                ;;
            13)
                show_progress "Installing CloudLinux"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) CloudLinux && RcLicenseCLN && t4srcCLN -install" "CloudLinux installation"
                ;;
            14)
                show_progress "Installing SitePad"
                check_command "bash <(curl -s https://mirror.resellercenter.ir/pre.sh) Sitepad && RcLicenseSitepad" "SitePad installation"
                ;;
            0)
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice: $choice${NC}"
                ;;
        esac
    done

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
