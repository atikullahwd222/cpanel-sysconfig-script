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
echo -e "                     /____/                     V1.5 "
echo -e ""
echo -e ""
echo -e ""
                                                  

echo "=============--- BH System v1.5 | Theme4Sell ---============="
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
echo "Select an installation option:                                "
echo -e "1. All in One ${RED}(For Beginner)${NC}                       "
echo "2. Initialize Theme4Sell                                      "
echo "3. Update WHM with Theme4Sell                                 "
echo "4. Fix WHM Lic. with Theme4Sell                               "
echo "5. Install and Active LiteSpeedX                              "
echo "6. Tweak Settings                                             "
echo "7. Install Softaculous                                        "
echo "8. Active Softaculous                                         "
echo "9. Install and active Jetbackup                               "
echo "10. Install and active Whmreseller                            "
echo "11. Install and Active sitepad                                "
echo "12. Install and Active Im360                                  "
echo "13. Install and CSF                                           "
echo "14. Active all CSF Fireall Security Rules                     "
echo "15. Install Cloudlinux                                        "
echo "16. Install Enable Cloudlinux                                 "
echo -e "${RED}0. Go Back${NC}"
echo "=============--- BH System v1.5 | Theme4Sell ---============="
read -p "Enter your choice (0-3): " choice


if [[ "$choice" == "1" ]]; then
    echo "===================================================================================================="
    install_cpanel=$(prompt_input "Do you want to install cPanel? (y/n)")
    install_litespeed=$(prompt_input "Do you want to install and activate LiteSpeed License? (y/n)")
    install_softaculous=$(prompt_input "Do you want to install Softaculous? (y/n)")
    install_jetbackup=$(prompt_input "Do you want to install JetBackup? (y/n)")
    install_whmreseller=$(prompt_input "Do you want to install WHMReseller? (y/n)")
    install_sitepad=$(prompt_input "Do you want to install SitePad? (y/n)")
    install_im360=$(prompt_input "Do you want to install Imunify360? (y/n)")
    install_cloudlinux=$(prompt_input "Do you want to install CloudLinux? (y/n)")
    echo "===================================================================================================="

    echo "You have 30 seconds to decide whether to start the installation or not..."
    sleep 30


    echo "Do you want to proceed with the installation? (y/n)"
    read proceed

    # Installing cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        cd /home
        curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
        sleep 2
        echo -e "${GREEN}Installing Our License System .....${NC}"
        sleep 2
        # Running MagicByte repo script
        curl -sL http://theme4sell.com/init.sh | sudo bash -
        clear
        echo -e "${GREEN}License System Installed Successfully.. ${NC}"    
        sleep 2        
        echo -e "${GREEN}License System Installed Successfully.. ${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Activating License ...........${NC}"
        sleep 2
        t4slic cpanel update
        t4slic cpanel enable
        t4slic cpanel fleetssl
        t4slic cpanel noupdate
    
    
    sleep 2
    echo -e "${GREEN} Enable Tweak settings.... ${NC}"
    sleep 2
    echo "===================================================================="

    whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube

    whmapi1 set_tweaksetting key=php_upload_max_filesize value=550

    whmapi1 set_tweaksetting key=php_post_max_size value=550

    whmapi1 set_tweaksetting key=maxemailsperhour value=30

    whmapi1 set_tweaksetting key=emailsperdaynotify value=100

    whmapi1 set_tweaksetting key=publichtmlsubsonly value=0

    whmapi1 set_tweaksetting key=resetpass value=0

    whmapi1 set_tweaksetting key=resetpass_sub value=0

    whmapi1 set_tweaksetting key=allowremotedomains value=1

    whmapi1 set_tweaksetting key=referrerblanksafety value=1
    
    whmapi1 set_tweaksetting key=referrersafety value=1
    
    whmapi1 set_tweaksetting key=cgihidepass value=1
    
    whmapi1 set_tweaksetting key=resetpass value=0
    
    whmapi1 set_tweaksetting key=resetpass_sub value=0

    mkdir /etc/cpanel/ea4/profiles/custom
    curl -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-t4slic-script/refs/heads/main/EasyApache4-BH-Custome.json

    echo -e "${GREEN} Tweak settings Successfull ${NC}"
    echo "===================================================================="

    else
        echo "Skipping cPanel installation. Exiting..."
        exit 1
    fi

    # Installing and enabling LiteSpeedX
    if [[ "$install_litespeed" == "y" ]]; then
        t4slic litespeedx install
        t4slic litespeedx enable
    fi

    # Installing and enabling Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        t4slic softaculous install
        echo "Please visit https://www.softaculous.com/trial/ to get a trial license."
    fi

    # Installing and enabling JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        t4slic jetbackup install
        t4slic jetbackup enable
    fi

    # Installing and enabling WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        t4slic whmreseller install
        t4slic whmreseller enable
    fi

    # Installing and enabling SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        t4slic sitepad install
        t4slic sitepad enable
    fi

    # Installing and enabling Imunify360
    if [[ "$install_im360" == "y" ]]; then
        t4slic im360 install
        t4slic im360 enable
    fi

    # Running StarLicense basic needs script
    bash <( curl https://api.starlicense.net/basic-needs.sh )

    # Installing and enabling CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        t4slic cloudlinux install
        t4slic cloudlinux enable
    fi

    # Final confirmation
    echo "Successful......"
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    clear
    t4s

elif [[ "$choice" == "2" ]]; then
    clear
    echo -e "${YELLOW}Initializing Theme4Sell Binaries....${NC}"
    sleep 2
    curl -sL https://repo.magicbyte.pw/init.sh | sudo bash -
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "3" ]]; then
    clear
    echo -e "${YELLOW}Updating WHM to Recommended Version....${NC}"
    sleep 2
    t4slic cpanel update
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "4" ]]; then
    clear
    echo -e "${YELLOW}Installing WHM License....${NC}"
    sleep 2
    t4slic cpanel enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "5" ]]; then
    clear
    echo -e "${YELLOW}Installing Litespeedx....${NC}"
    sleep 2
    t4slic litespeedx install
    
    clear
    echo -e "${YELLOW}Installing Litespeedx License....${NC}"
    sleep 2
    t4slic litespeedx enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "6" ]]; then
    echo "===================================================================="
    echo "${YELLOW} Enable Tweak settings.... ${NC}"

    whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube

    whmapi1 set_tweaksetting key=php_upload_max_filesize value=550

    whmapi1 set_tweaksetting key=php_post_max_size value=550

    whmapi1 set_tweaksetting key=maxemailsperhour value=30

    whmapi1 set_tweaksetting key=emailsperdaynotify value=100

    whmapi1 set_tweaksetting key=publichtmlsubsonly value=0

    whmapi1 set_tweaksetting key=resetpass value=0

    whmapi1 set_tweaksetting key=resetpass_sub value=0

    whmapi1 set_tweaksetting key=allowremotedomains value=1

    whmapi1 set_tweaksetting key=referrerblanksafety value=1
    
    whmapi1 set_tweaksetting key=referrersafety value=1
    
    whmapi1 set_tweaksetting key=cgihidepass value=1
    
    whmapi1 set_tweaksetting key=resetpass value=0
    
    whmapi1 set_tweaksetting key=resetpass_sub value=0

    whmapi1 set_tweaksetting key=skipboxtrapper value=1

    mkdir /etc/cpanel/ea4/profiles/custom
    curl -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-t4slic-script/refs/heads/main/EasyApache4-BH-Custome.json

    echo "${GREEN} Tweak settings Successfull ${NC}"
    echo "===================================================================="
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s
elif [[ "$choice" == "7" ]]; then
    clear
    echo -e "${YELLOW}Installing Softaculous....${NC}"
    sleep 2
    t4slic softaculous install
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "8" ]]; then
    clear
    echo -e "${YELLOW}Installing Softaculous License....${NC}"
    sleep 2
    t4slic softaculous enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "9" ]]; then
    clear
    echo -e "${YELLOW}Installing Jetbackup....${NC}"
    sleep 2
    t4slic jetbackup install
    
    clear
    echo -e "${YELLOW}Installing Jetbackup License....${NC}"
    sleep 2
    t4slic jetbackup enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s
elif [[ "$choice" == "10" ]]; then
    clear
    echo -e "${YELLOW}Installing Whmreseller....${NC}"
    sleep 2
    t4slic whmreseller install

    clear
    echo -e "${YELLOW}Installing Whmreseller License....${NC}"
    sleep 2
    t4slic whmreseller enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "11" ]]; then
    clear
    echo -e "${YELLOW}Installing Sitepad....${NC}"
    sleep 2
    t4slic sitepad install
    
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear

    echo -e "${YELLOW}Installing Sitepad License....${NC}"
    sleep 2
    t4slic sitepad enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "12" ]]; then
    clear
    echo -e "${YELLOW}Installing Imunify 360 Sitepad....${NC}"
    sleep 2
    t4slic im360 install
    
    clear
    echo -e "${YELLOW}Installing Imunify 360 Sitepad License ....${NC}"
    sleep 2
    t4slic im360 enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "13" ]]; then
    clear
    echo -e "${YELLOW}Installing CSF (Security Plugin) ....${NC}"
    sleep 2
    bash <( curl https://api.starlicense.net/basic-needs.sh )
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "14" ]]; then
    clear
    echo -e "${YELLOW}Installing CSF Security recommended Rules ....${NC}"
    sleep 2
    sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/alt/php*/etc/php.ini
    sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/cpanel/ea-php*/root/etc/php.ini
    sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/alt/php*/etc/php.ini
    sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/cpanel/ea-php*/root/etc/php.ini
    sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/alt/php-internal/etc/php.ini
    /bin/systemctl stop rpcbind
    /bin/systemctl disable rpcbind
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "15" ]]; then
    clear
    echo -e "${YELLOW}Installing Cloudlinux ....${NC}"
    sleep 2
    t4slic cloudlinux install
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s

elif [[ "$choice" == "16" ]]; then
    clear
    echo -e "${YELLOW}Installing Cloudlinux License ....${NC}"
    sleep 2
    t4slic cloudlinux enable
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s
elif [[ "$choice" == "0" ]]; then
    echo ""
    echo -e "${GREEN}Is everything Currect? (y/n)${NC}"
    read proceed
    clear
    t4s
else
    echo -e "${RED}Invalid option! Please select 1-4.${NC}"
    exit 0
fi
