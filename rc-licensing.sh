#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt user for input
prompt_input() {
    read -p "$1: " input
    echo "$input"
}

clear

# Display installation options
echo -e "    ____  __  __   _____            __               "
echo -e "   / __ )/ / / /  / ___/__  _______/ /____  ____ ___ "
echo -e "  / __  / /_/ /   \__ \/ / / / ___/ __/ _ \/ __ \`__ \\ "
echo -e " / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / /"
echo -e "/_____/_/_/_/_  /____/\__, /____/\__/\___/_/ /_/ /_/ "
echo -e "                     /____/                     V$T4S_VERSION "
echo -e ""
echo -e ""
echo -e ""
                                                  

echo "=============--- BH System V$T4S_VERSION | RC Licensing ---============="
echo ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo ""
echo -e "${YELLOW}Do Basic Config part before start installation..${NC}"
echo -e "${YELLOW}Go to main menu for do the basic config.${NC}"
echo -e "${YELLOW}Press 0 to go back Main menu${NC}"
echo ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo ""
echo ""
echo "Select an installation option:"
echo -e "1. All in One Auto Installer ${RED}(For Beginner)${NC}"
echo -e "2. Cpanel RC"
echo -e "${RED}0. Go Back${NC}"
echo "=============--- BH System V$T4S_VERSION | Theme4Sell ---============="
read -p "Enter your choice (0-2): " choice


if [[ "$choice" == "1" ]]; then
    echo "===================================================================================================="
    remove_license=$(prompt_input "Do you want to remove the existing license? (y/n)")
    install_cpanel=$(prompt_input "Do you want to install cPanel VPS ${YELLOW}(Select Carefully)${NC} ? (y/n)")
    # install_dedicated=$(prompt_input "Do you want to install Cpanel Dedicated ${YELLOW}(Select Carefully)${NC} ? (y/n)")
    install_litespeed=$(prompt_input "Do you want to install and activate LiteSpeed License? (y/n)")
    install_softaculous=$(prompt_input "Do you want to install Softaculous? (y/n)")
    install_jetbackup=$(prompt_input "Do you want to install JetBackup? (y/n)")
    install_whmreseller=$(prompt_input "Do you want to install WHMReseller? (y/n)")
    install_im360=$(prompt_input "Do you want to install Imunify360 ${YELLOW}(Select Carefully)${NC} ? (y/n)")
    install_cpguard=$(prompt_input "Do you want to install cPGuard ${YELLOW}(Select Carefully)${NC} ? (y/n)")
    install_dareseller=$(prompt_input "Do you want to install Da-Reseller? (y/n)")
    install_osm=$(prompt_input "Do you want to install OSM? (y/n)")
    install_cxs=$(prompt_input "Do you want to install CXS? (y/n)")
    install_cloudlinux=$(prompt_input "Do you want to install CloudLinux? (y/n)")
    install_sitepad=$(prompt_input "Do you want to install SitePad? (y/n)")
    echo "===================================================================================================="

    echo "You have 5 seconds to decide whether to start the installation or not..."
    sleep 5


    echo "Do you want to proceed with the installation? (y/n)"
    read proceed


    if [[ "$remove_license" == "y" ]]; then
        wget -O remover https://mirror.resellercenter.ir/remover; chmod +x remover; ./remover
    fi
    # Installing cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        echo -e "${GREEN}Installing WHM/cPanel .....${NC}"
        sleep 2
        cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
        sleep 2
        echo ""    
        
        echo ""    
        clear
        sleep 2        
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Activating License ...........${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) cPanel; RcLicenseCP
        RcLicenseCP -fleetssl
        sleep 2
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}cPanel Installation Completed!${NC}"
        sleep 2
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Tweak Settings in progress....${NC}"
        sleep 2
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) &>/dev/null
        sleep 2
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Tweak Settings Completed!${NC}"
    fi

    # Installing and enabling LiteSpeedX
    if [[ "$install_litespeed" == "y" ]]; then
        echo -e "${GREEN}Installing LiteSpeed .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) liteSpeed; RcLicenseLSWS
        sleep 2
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}LiteSpeed Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        echo -e "${GREEN}Installing Softaculous .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Softaculous; RcLicenseSoftaculous
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Softaculous Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        echo -e "${GREEN}Installing JetBackup .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) JetBackup; RcLicenseJetBackup
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}JetBackup Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        echo -e "${GREEN}Installing WHMReseller .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) WHMReseller; RcLicenseWHMReseller
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}WHMReseller Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling Imunify360
    if [[ "$install_im360" == "y" ]]; then
        echo -e "${GREEN}Installing Imunify360 .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Imunify360; RcLicenseImunify360
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Imunify360 Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        echo -e "${GREEN}Installing CloudLinux .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CloudLinux; RcLicenseCLN
        t4srcCLN -install
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}CloudLinux Installation Completed!${NC}"
        sleep 2
    fi

    # Installing and enabling SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        echo -e "${GREEN}Installing SitePad .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) Sitepad; RcLicenseSitepad
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}SitePad Installation Completed!${NC}"
        sleep 2
    fi

    if [[ "$install_cpguard" == "y" ]]; then
        echo -e "${GREEN}Installing cPGuard .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CPGuard; RcLicenseCPGuard
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}cPGuard Installation Completed!${NC}"
        sleep 2
    fi

    if [[ "$install_dareseller" == "y" ]]; then
        echo -e "${GREEN}Installing Da-Reseller .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) DAReseller; RcLicenseDAReseller
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Da-Reseller Installation Completed!${NC}"
        sleep 2
    fi

    if [[ "$install_osm" == "y" ]]; then
        echo -e "${GREEN}Installing OSM .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) OSM; RcLicenseOSM
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}OSM Installation Completed!${NC}"
        sleep 2
    fi

    if [[ "$install_cxs" == "y" ]]; then
        echo -e "${GREEN}Installing CXS .....${NC}"
        sleep 2
        bash <( curl https://mirror.resellercenter.ir/pre.sh ) CXS; RcLicenseCXS
        sleep 2
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}CXS Installation Completed!${NC}"
        sleep 2
    fi

elif [[ "$choice" == "2" ]]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Activating License ...........${NC}"
    sleep 2
    bash <( curl https://mirror.resellercenter.ir/pre.sh ) cPanel; RcLicenseCP
    # RcLicenseCP -fleetssl
    sleep 2
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}RC Cpanel Activation Completed!${NC}"
    sleep 2

elif [[ "$choice" == "0" ]]; then
    echo -e "${RED}Going Back .....${NC}"
    sleep 1
    clear
    t4s
else
    echo -e "${RED}Invalid option! Please select 1-2.${NC}"
    exit 0
fi
