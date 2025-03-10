#!/bin/bash

# Define version variable
VERSION="3.0"

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
    read -p "Enter your choice (1-2): " action

    if [[ "$action" == "1" ]]; then
        echo -e "${YELLOW}Installing $product...${NC}"
        sysconfig $product install
        echo -e "${GREEN}$product installation completed.${NC}"
    elif [[ "$action" == "2" ]]; then
        echo -e "${YELLOW}Activating $product...${NC}"
        sysconfig $product enable
        echo -e "${GREEN}$product activation completed.${NC}"
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
    read -p "Enter your choice (1-2): " csf_action

    if [[ "$csf_action" == "1" ]]; then
        echo -e "${YELLOW}Installing CSF...${NC}"
        echo -e "${YELLOW}Please Wait...${NC}"
        bash <(curl https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/csf.sh) 2>&1
        echo -e "${GREEN}CSF installation completed.${NC}"

    elif [[ "$csf_action" == "2" ]]; then
        echo -e "${YELLOW}Installing CSF Security recommended Rules ....${NC}"
        sleep 2

        # Disable dynamic loading (enable_dl)
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/alt/php*/etc/php.ini 2>&1
        sleep 1
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/cpanel/ea-php*/root/etc/php.ini 2>&1
        sleep 1
        sed -i 's/^enable_dl = On/enable_dl = Off/' /opt/alt/php-internal/etc/php.ini 2>&1
        sleep 1

        # Disable dangerous functions
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/alt/php*/etc/php.ini 2>&1
        sleep 1
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/cpanel/ea-php*/root/etc/php.ini 2>&1
        sleep 1
        sed -i 's/^disable_functions *=.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' /opt/alt/php-internal/etc/php.ini 2>&1
        sleep 1

        # Disable rpcbind service
        echo -e "${YELLOW}Stopping and disabling rpcbind service...${NC}"
        /bin/systemctl stop rpcbind 2>&1
        /bin/systemctl disable rpcbind 2>&1
        sleep 2

        echo -e "${GREEN}CSF Security recommended rules have been applied successfully.${NC}"
        sleep 2
    else
        echo -e "${RED}Invalid choice for CSF. Please try again.${NC}"
    fi
}

clear

# Display the main menu with version control
echo -e "=============--- BH System v$VERSION | Theme4Sell ---============="
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
echo "3.  WHM/Cpanel                                                 "
echo "4.  LiteSpeedX                                                 "
echo "5.  Tweak Settings                                             "
echo "6.  Softaculous                                                "
echo "7.  JetBackup                                                  "
echo "8.  WHMReseller                                                "
echo "9.  SitePad                                                   "
echo "10. Imunify360                                                 "
echo "11. CSF                                                       "
echo "12. CloudLinux                                                 "
echo -e "${YELLOW}13. Auto License Active (Advanced)${NC}                       "
echo -e "${RED}0. Go Back${NC}"
echo "=============--- BH System v$VERSION | Theme4Sell ---============="
read -p "Enter your choice (0-13): " choice

# Handle each selection
if [[ "$choice" == "1" ]]; then
    # Handle All-in-One installation
    clear
    echo -e "${YELLOW}All in One installation selected. Let's begin...${NC}"
    # Prompt for installation or activation for each product
    install_or_activate "cpanel"
    install_or_activate "litespeedx"
    install_or_activate "softaculous"
    install_or_activate "jetbackup"
    install_or_activate "whmreseller"
    install_or_activate "im360"
    install_or_activate "cloudlinux"
    install_or_activate "sitepad"

elif [[ "$choice" == "2" ]]; then
    # Initialize Theme4Sell
    clear
    echo -e "${YELLOW}Initializing Theme4Sell Binaries....${NC}"
    sleep 2
    curl -sL https://repo.magicbyte.pw/setup.sh | sudo bash - 
    sleep 2
    t4s budget

elif [[ "$choice" == "3" || "$choice" == "4" || "$choice" == "5" || "$choice" == "6" || "$choice" == "7" || "$choice" == "8" || "$choice" == "9" || "$choice" == "10" || "$choice" == "11" || "$choice" == "12" ]]; then
    # Handle product installation or activation
    case $choice in
        3) product="cpanel" ;;
        4) product="litespeedx" ;;
        5) product="tweak settings" ;;
        6) product="softaculous" ;;
        7) product="jetbackup" ;;
        8) product="whmreseller" ;;
        9) product="sitepad" ;;
        10) product="im360" ;;
        11) csf_options ;;
        12) product="cloudlinux" ;;
        *) echo -e "${RED}Invalid choice. Exiting...${NC}" && exit 1 ;;
    esac
    install_or_activate "$product"

# elif [[ "$choice" == "11" ]]; then
#     # Handle CSF-specific options
#     csf_options

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
