#!/bin/bash

# Define version variable
source <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/version.sh)

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

# Function to install or activate product
install_or_activate() {
    local product=$1
    echo -e "${YELLOW}You selected: $product.${NC}"
    echo "Choose an action:"
    echo "1. Install $product"
    echo "2. Activate $product"
    echo "0. Go to Home"
    read -p "Enter your choice (0-2): " action

    if [[ "$action" == "1" ]]; then
        echo -e "${YELLOW}Installing $product...${NC}"
        sysconfig $product install
        echo -e "${GREEN}$product installation completed.${NC}"
    elif [[ "$action" == "2" ]]; then
        echo -e "${YELLOW}Activating $product...${NC}"
        sysconfig $product enable
        echo -e "${GREEN}$product activation completed.${NC}"
    elif [[ "$action" == "0" ]]; then
        echo -e "${YELLOW}Going to Home...${NC}"
        sleep 1
        t4s budget
    else
        echo -e "${RED}Invalid choice. Please try again.${NC}"
    fi
}

# Function for CSF option
csf_options() {
    echo -e "You selected CSF."
    echo "Choose an action:"
    echo "1. Install CSF"
    echo "2. Activate CSF rules"
    echo "0. Go back"
    read -p "Enter your choice (0-2): " csf_action

    if [[ "$csf_action" == "1" ]]; then
        echo -e "${YELLOW}Installing CSF...${NC}"
        echo -e "${YELLOW}Please Wait...${NC}"
        bash <(curl https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/csf.sh) &>/dev/null
        echo -e "${GREEN}CSF installation completed.${NC}"

    elif [[ "$csf_action" == "2" ]]; then
        echo -e "${YELLOW}Installing CSF Security recommended Rules ....${NC}"
        sleep 2

        # Disable dynamic loading (enable_dl)
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/alt/php*/etc/php.ini &>/dev/null
        sleep 1
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/cpanel/ea-php*/root/etc/php.ini &>/dev/null
        sleep 1
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/alt/php-internal/etc/php.ini &>/dev/null
        sleep 1

        # Disable dangerous functions
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, mail/' /opt/alt/php*/etc/php.ini &>/dev/null
        sleep 1
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, mail/' /opt/cpanel/ea-php*/root/etc/php.ini &>/dev/null
        sleep 1
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, mail/' /opt/alt/php-internal/etc/php.ini &>/dev/null
        sleep 1

        # Disable rpcbind service
        echo -e "${YELLOW}Stopping and disabling rpcbind service...${NC}"
        /bin/systemctl stop rpcbind &>/dev/null
        /bin/systemctl disable rpcbind &>/dev/null
        sleep 2

        echo -e "${GREEN}CSF Security recommended rules have been applied successfully.${NC}"
        sleep 2
    elif [[ "$csf_action" == "2" ]]; then
        t4s budget
    else
        echo -e "${RED}Invalid choice for CSF. Please try again.${NC}"
    fi
}

tweak_settings() {
    bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
}

clear

# Display the main menu with version control
echo -e "=============--- BH System V$T4S_VERSION | Theme4Sell ---============="
echo -e ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo -e ""
echo -e "${YELLOW}Do Basic Config part before start installation..${NC}"
echo -e "${YELLOW}Go to main menu for do the basic config.${NC}"
echo -e "${YELLOW}Press 0 to go back Main menu${NC}"
echo -e ""
echo -e "${RED}******************* ⚠ WARNING ⚠ *******************${NC}"
echo -e ""
echo -e ""
echo "Select an installation option:                                "
echo -e "1.  All in One ${RED}(For Beginner)${NC}                   "
echo "2.  Initialize Theme4Sell                                     "
echo "3.  WHM/Cpanel                                                "
echo "4.  Tweak Settings                                            "
echo "5.  LiteSpeedX                                                "
echo "6.  Softaculous                                               "
echo "7.  JetBackup                                                 "
echo "8.  WHMReseller                                               "
echo "9.  SitePad                                                   "
echo "10. Imunify360                                                "
echo "11. CSF                                                       "
echo "12. CloudLinux                                                "
echo -e "${YELLOW}13. Auto License Active (Advanced)${NC}           "
echo -e "${RED}0. Go Back${NC}"
echo "=============--- BH System V$T4S_VERSION | Theme4Sell ---============="
read -p "Enter your choice (0-13): " choice

# Handle each selection
if [[ "$choice" == "1" ]]; then
    echo "===================================================================================================="
    install_cpanel=$(prompt_input "Do you want to install cPanel? (y/n)")
    install_litespeed=$(prompt_input "Do you want to install and activate LiteSpeed License? (y/n)")
    install_softaculous=$(prompt_input "Do you want to install Softaculous? (y/n)")
    install_jetbackup=$(prompt_input "Do you want to install JetBackup? (y/n)")
    install_whmreseller=$(prompt_input "Do you want to install WHMReseller? (y/n)")
    install_im360=$(prompt_input "Do you want to install Imunify360? (y/n)")
    install_cloudlinux=$(prompt_input "Do you want to install CloudLinux? (y/n)")
    install_sitepad=$(prompt_input "Do you want to install SitePad? (y/n)")
    echo "===================================================================================================="

    echo "You have 5 seconds to decide whether to start the installation or not..."
    sleep 5


    echo "Do you want to proceed with the installation? (y/n)"
    read proceed

    # Installing cPanel
    if [[ "$install_cpanel" == "y" ]]; then
        echo -e "${GREEN}Installing Our License System .....${NC}"
        sleep 2
        # Running MagicByte repo script
        curl -sL https://repo.magicbyte.pw/setup.sh | sudo bash -

        # sysconfig cpanel install
        cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
        sleep 2
        echo ""    
        echo ""    
        echo -e "${GREEN}License System Installed Successfully.. ${NC}"    
        echo ""    
        clear
        sleep 2        
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Activating License ...........${NC}"
        sleep 2
        sysconfig cpanel update
        sysconfig cpanel enable
        sysconfig cpanel fleetssl
        sysconfig cpanel noupdate
    
        sleep 2
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
    fi

    # Installing and enabling LiteSpeedX
    if [[ "$install_litespeed" == "y" ]]; then
        sysconfig litespeedx install
        sysconfig litespeedx enable
    fi

    # Installing and enabling Softaculous
    if [[ "$install_softaculous" == "y" ]]; then
        sysconfig softaculous install
        sysconfig softaculous enable
        # echo "Please visit https://www.softaculous.com/trial/ to get a trial license."
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

    # Installing and enabling Imunify360
    if [[ "$install_im360" == "y" ]]; then
        sysconfig im360 install
        sysconfig im360 enable
    fi

    # Installing and enabling CloudLinux
    if [[ "$install_cloudlinux" == "y" ]]; then
        sysconfig cloudlinux install
        sysconfig cloudlinux enable
    fi

    # Installing and enabling SitePad
    if [[ "$install_sitepad" == "y" ]]; then
        sysconfig sitepad install
        sysconfig sitepad enable
    fi

    # Final confirmation
    echo "Successful......"
    sleep 2
    echo -e "${GREEN}Redirecting.....${NC}"

elif [[ "$choice" == "2" ]]; then
    # Initialize Theme4Sell
    clear
    echo -e "${YELLOW}Initializing Theme4Sell Binaries....${NC}"
    sleep 2
    curl -sL https://repo.magicbyte.pw/setup.sh | sudo bash - 
    sleep 2
    t4s budget

elif [[ "$choice" == "3" || "$choice" == "5" || "$choice" == "6" || "$choice" == "7" || "$choice" == "8" || "$choice" == "9" || "$choice" == "10" || "$choice" == "12" ]]; then
    # Handle product installation or activation
    case $choice in
        3) product="cpanel" ;;
        5) product="litespeedx" ;;
        6) product="softaculous" ;;
        7) product="jetbackup" ;;
        8) product="whmreseller" ;;
        9) product="sitepad" ;;
        10) product="im360" ;;
        12) product="cloudlinux" ;;
        *) echo -e "${RED}Invalid choice. Exiting...${NC}" && exit 1 ;;
    esac
    install_or_activate "$product"

elif [[ "$choice" == "4"]]; then
    # Tweak Settings
    tweak_settings
    
elif [[ "$choice" == "11" ]]; then
    # Handle CSF-specific options
    csf_options
    t4s budget

elif [[ "$choice" == "13" ]]; then
    # Auto License Activation
    clear
    echo -e "${YELLOW}Auto License Activation....${NC}"
    sleep 2
    bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/master/Auto-Activate-CloudLicense.sh)

elif [[ "$choice" == "0" ]]; then
    # Go back to the main menu
    exit
fi
