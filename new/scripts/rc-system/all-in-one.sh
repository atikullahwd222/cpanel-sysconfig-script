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
source $HEADER_URL

# ----------------------------
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