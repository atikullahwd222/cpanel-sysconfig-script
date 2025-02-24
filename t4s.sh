#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}ERROR: curl is not installed. Please install curl and try again.${NC}"
    exit 1
fi

# Ensure we are running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Warning: You are not running as root. You may need to enter sudo passwords during installation.${NC}"
fi

# Function to handle errors
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Main function to handle commands
case "$1" in
    "budget")
        echo -e "${GREEN}You selected Budget Licensing System.${NC}"
        echo ""
        echo ""
        echo -e "${YELLOW}Redirecting...${NC}"
        echo ""
        sleep 1
        clear
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        ;;
    "tweak")
        echo "===================================================================="
        echo -e "${YELLOW} Enabling Tweak Settings... ${NC}"

        echo "Configuring PHP settings..."
        whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube &>/dev/null
        whmapi1 set_tweaksetting key=php_upload_max_filesize value=550 &>/dev/null
        whmapi1 set_tweaksetting key=php_post_max_size value=550 &>/dev/null

        echo "Setting email limits..."
        whmapi1 set_tweaksetting key=maxemailsperhour value=30 &>/dev/null
        whmapi1 set_tweaksetting key=emailsperdaynotify value=100 &>/dev/null

        echo "Allowing public_html subdirectories..."
        whmapi1 set_tweaksetting key=publichtmlsubsonly value=0 &>/dev/null

        echo "Disabling password resets..."
        whmapi1 set_tweaksetting key=resetpass value=0 &>/dev/null
        whmapi1 set_tweaksetting key=resetpass_sub value=0 &>/dev/null

        echo "Applying security settings..."
        whmapi1 set_tweaksetting key=allowremotedomains value=1 &>/dev/null
        whmapi1 set_tweaksetting key=referrerblanksafety value=1 &>/dev/null
        whmapi1 set_tweaksetting key=referrersafety value=1 &>/dev/null
        whmapi1 set_tweaksetting key=cgihidepass value=1 &>/dev/null

        echo "Updating MySQL settings..."
        grep -q '^sql_mode=' /etc/my.cnf && sed -i 's/^sql_mode=.*/sql_mode=""'/ /etc/my.cnf || sed -i '/^\[mysqld\]/a sql_mode=""' /etc/my.cnf
        /scripts/restartsrv_mysql &>/dev/null

        echo "Downloading custom EasyApache 4 profile..."
        mkdir -p /etc/cpanel/ea4/profiles/custom &>/dev/null
        curl -s -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json &>/dev/null

        echo -e "${GREEN} Tweak settings successfully applied! ${NC}"
        echo "===================================================================="
        ;;
    "")
        echo -e "${GREEN}Fetching the latest script version...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh) || error_exit "Failed to execute t4s"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        exit 1
        ;;
esac
