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
echo -e "${GREEN}      ____  __  __   _____            __               "
echo -e "${GREEN}     / __ )/ / / /  / ___/__  _______/ /____  ____ ___ "
echo -e "${GREEN}    / __  / /_/ /   \__ \/ / / / ___/ __/ _ \/ __ \`__ \\"
echo -e "${GREEN}   / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / /"
echo -e "${GREEN}  /_____/_/_/_/_  /____/\__, /____/\__/\___/_/ /_/ /_/ "
echo -e "${GREEN}   _   _<  /|__ \      /____/                          "
echo -e "${GREEN}  | | / / / __/ /                                      "
echo -e "${GREEN}  | |/ / / / __/                                       "
echo -e "${GREEN}  |___/_(_)____/                                       "
echo -e "${GREEN}                                                       "

                                                  

echo "=================== BH System v1.2 ============================"
echo "Select an installation option:                                "
echo "${GREEN} 1. Install WHM                                                "
echo "${GREEN} 2. Initialize Theme4Sell                                      "
echo "${GREEN} 3. Activate or Fix WHM Lic. with Theme4Sell                   "
echo "${GREEN} 4. Install and Active LiteSpeedX                              "
echo "${GREEN} 5. Tweak Settings                                             "
echo "${GREEN} 6. Install Softaculous                                        "
echo "${GREEN} 7. Active Softaculous                                         "
echo "${GREEN} 8. Install and active Jetbackup                               "
echo "${GREEN} 9. Install and active Whmreseller                             "
echo "${GREEN} 10. Install and Active sitepad                                "
echo "${GREEN} 11. Install and Active Im360                                  "
echo "${GREEN} 12. Install and CSF                                           "
echo "${GREEN} 13. Install Cloudlinux                                        "
echo "${GREEN} 14. Install Enable Cloudlinux                                 "
echo "${RED} 15. Ready the server for WHM                                  "
echo "${GREEN} 0. Fresh install with Theme4Sell                              "
echo "=================== BH System v1.2 ============================"
read -p "Enter your choice (0-3): " choice

if [[ "$choice" == "1" ]]; then
    echo "This script will configure system settings and install cPanel."
    read -p "Do you want to continue? (y/n): " confirm_choice
    if [[ "$confirm_choice" == "y" ]]; then
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
    fi
    else
        cd /home
        curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
    fi

elif [[ "$choice" == "2" ]]; then
    curl -sL https://repo.magicbyte.pw/init.sh | sudo bash -

elif [[ "$choice" == "3" ]]; then
    sysconfig cpanel update
    sysconfig cpanel enable

elif [[ "$choice" == "4" ]]; then
    sysconfig litespeedx install
    sysconfig litespeedx enable

elif [[ "$choice" == "5" ]]; then
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

elif [[ "$choice" == "6" ]]; then
    sysconfig softaculous install

elif [[ "$choice" == "7" ]]; then
    sysconfig softaculous enable

elif [[ "$choice" == "8" ]]; then
    sysconfig jetbackup install
    sysconfig jetbackup enable

elif [[ "$choice" == "9" ]]; then
    sysconfig whmreseller install
    sysconfig whmreseller enable

elif [[ "$choice" == "10" ]]; then
    sysconfig sitepad install
    sysconfig sitepad enable

elif [[ "$choice" == "11" ]]; then
    sysconfig im360 install
    sysconfig im360 enable

elif [[ "$choice" == "12" ]]; then
    bash <( curl https://api.starlicense.net/basic-needs.sh )

elif [[ "$choice" == "13" ]]; then
    sysconfig cloudlinux install

elif [[ "$choice" == "14" ]]; then
    sysconfig cloudlinux enable

elif [[ "$choice" == "15" ]]; then
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

elif [[ "$choice" == "0" ]]; then
    # Get user input
    server_ip=$(prompt_input "Enter the server IP")
    hostname=$(prompt_input "Enter the hostname")
    hostname_prefix=$(prompt_input "Enter the hostname prefix")

    # Update /etc/hosts
    echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

    # Setting up DNS resolvers
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

    # Installing nano text editor
    yum install nano -y

    # Updating system and installing AlmaLinux release
    yum update -y
    yum install almalinux-release -y

    # Disabling firewalld
    iptables-save > ~/firewall.rules
    systemctl stop firewalld.service
    systemctl disable firewalld.service

    clear
    # Confirm installation choices
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
