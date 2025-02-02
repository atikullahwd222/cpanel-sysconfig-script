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

# Display installation options
echo -e "    ____  __  __   _____            __               "
echo -e "   / __ )/ / / /  / ___/__  _______/ /____  ____ ___ "
echo -e "  / __  / /_/ /   \__ \/ / / / ___/ __/ _ \/ __ \`__ \\ "
echo -e " / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / /"
echo -e "/_____/_/_/_/_  /____/\__, /____/\__/\___/_/ /_/ /_/ "
echo -e " _   _<  /|__ \      /____/                          "
echo -e "| | / / / __/ /                                      "
echo -e "| |/ / / / __/                                       "
echo -e "|___/_(_)____/                                       "
echo -e "                                                     "

                                                  

echo "=================== BH System v1.2 ============================"
echo "Select an installation option:                                "
echo -e "${RED}1. Ready the server for WHM ${NC} ${GREEN}(Important)${NC}           "
echo "2. Install WHM                                                "
echo "3. Initialize Theme4Sell                                      "
echo "4. Activate or Fix WHM Lic. with Theme4Sell                   "
echo "5. Install and Active LiteSpeedX                              "
echo "6. Tweak Settings                                             "
echo "7. Install Softaculous                                        "
echo "8. Active Softaculous                                         "
echo "9. Install and active Jetbackup                               "
echo "10. Install and active Whmreseller                             "
echo "11. Install and Active sitepad                                "
echo "12. Install and Active Im360                                  "
echo "13. Install and CSF                                           "
echo "14. Install Cloudlinux                                        "
echo "15. Install Enable Cloudlinux                                 "
echo "0. Fresh install with Theme4Sell                              "
echo "=================== BH System v1.2 ============================"
read -p "Enter your choice (0-3): " choice

if [[ "$choice" == "1" ]]; then
        server_ip=$(prompt_input "Enter the server IP")
        hostname=$(prompt_input "Enter the hostname")
        hostname_prefix=$(prompt_input "Enter the hostname prefix")

        echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

        echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
        echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

        yum install nano -y
        yum update -y
        yum install almalinux-release -y
        iptables-save > ~/firewall.rules
        systemctl stop firewalld.service
        systemctl disable firewalld.service


        clear

        echo -e "${RED}The Server need a reboot.....${NC}"
        echo -e "${RED}ctrl+c${NC} ${GREEN}To avoid restart${NC}"
        sleep 30
        echo -e "${RED}After Reboot run t4s again to continue ${NC}"
        echo -e "${RED}Rebooting ${NC}"
        sleep 3

        reboot now

elif [[ "$choice" == "2" ]]; then
    cd /home
    curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest

elif [[ "$choice" == "3" ]]; then
    curl -sL https://repo.magicbyte.pw/init.sh | sudo bash -

elif [[ "$choice" == "4" ]]; then
    sysconfig cpanel update
    sysconfig cpanel enable

elif [[ "$choice" == "5" ]]; then
    sysconfig litespeedx install
    sysconfig litespeedx enable

elif [[ "$choice" == "6" ]]; then
    echo "===================================================================="
    echo "${GREEN} Enable Tweak settings.... ${NC}"

    whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube

    whmapi1 set_tweaksetting key=php_upload_max_filesize value=550

    whmapi1 set_tweaksetting key=php_post_max_size value=550

    whmapi1 set_tweaksetting key=maxemailsperhour value=30

    whmapi1 set_tweaksetting key=emailsperdaynotify value=100

    whmapi1 set_tweaksetting key=publichtmlsubsonly value=0

    whmapi1 set_tweaksetting key=resetpass value=0

    whmapi1 set_tweaksetting key=resetpass_sub value=0

    whmapi1 set_tweaksetting key=allowremotedomains value=1

    mkdir /etc/cpanel/ea4/profiles/custom
    curl -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json

    echo "${GREEN} Tweak settings Successfull ${NC}"
    echo "===================================================================="

elif [[ "$choice" == "7" ]]; then
    sysconfig softaculous install

elif [[ "$choice" == "8" ]]; then
    sysconfig softaculous enable

elif [[ "$choice" == "9" ]]; then
    sysconfig jetbackup install
    sysconfig jetbackup enable

elif [[ "$choice" == "10" ]]; then
    sysconfig whmreseller install
    sysconfig whmreseller enable

elif [[ "$choice" == "11" ]]; then
    sysconfig sitepad install
    sysconfig sitepad enable

elif [[ "$choice" == "12" ]]; then
    sysconfig im360 install
    sysconfig im360 enable

elif [[ "$choice" == "13" ]]; then
    bash <( curl https://api.starlicense.net/basic-needs.sh )

elif [[ "$choice" == "14" ]]; then
    sysconfig cloudlinux install

elif [[ "$choice" == "15" ]]; then
    sysconfig cloudlinux enable

elif [[ "$choice" == "0" ]]; then
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
        # Running MagicByte repo script
        curl -sL https://repo.magicbyte.pw/init.sh | sudo bash -
        sysconfig cpanel update
        sysconfig cpanel enable
        sysconfig cpanel fleetssl
        sysconfig cpanel noupdate

        echo "Enable Tweak settings...."

        whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube

        whmapi1 set_tweaksetting key=php_upload_max_filesize value=550

        whmapi1 set_tweaksetting key=php_post_max_size value=550

        whmapi1 set_tweaksetting key=maxemailsperhour value=30

        whmapi1 set_tweaksetting key=emailsperdaynotify value=100

        whmapi1 set_tweaksetting key=publichtmlsubsonly value=0

        whmapi1 set_tweaksetting key=resetpass value=0

        whmapi1 set_tweaksetting key=resetpass_sub value=0

        whmapi1 set_tweaksetting key=allowremotedomains value=1

        mkdir /etc/cpanel/ea4/profiles/custom
        curl -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json

    else
        echo "Skipping cPanel installation. Exiting..."
        exit 1
    fi

    # Installing and enabling LiteSpeedX
    if [[ "$install_litespeed" == "y" ]]; then
        sysconfig litespeedx install
        sysconfig litespeedx enable
    fi

    # Installing and enabling Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        sysconfig softaculous install
        echo "Please visit https://www.softaculous.com/trial/ to get a trial license."
    fi

    # Installing and enabling JetBackup
    if [[ "$install_jetbackup" == "y" ]]; then
        sysconfig jetbackup install
        sysconfig jetbackup enable
    fi

    # Installing and enabling WHMReseller
    if [[ "$install_whmreseller" == "y" ]]; then
        sysconfig whmreseller install
        sysconfig whmreseller enable
    fi

    # Installing and enabling SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        sysconfig sitepad install
        sysconfig sitepad enable
    fi

    # Installing and enabling Imunify360
    if [[ "$install_im360" == "y" ]]; then
        sysconfig im360 install
        sysconfig im360 enable
    fi

    # Running StarLicense basic needs script
    bash <( curl https://api.starlicense.net/basic-needs.sh )

    # Installing and enabling CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        sysconfig cloudlinux install
        sysconfig cloudlinux enable
    fi

    # Final confirmation
    echo "Successful......"

else
    echo "Invalid choice. Exiting..."
    exit 1
fi

echo "Installation process completed."
