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
        echo -e "${GREEN}Starting tweak settings...${NC}"
        
        whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube || error_exit "Failed to set phploader"
        whmapi1 set_tweaksetting key=php_upload_max_filesize value=550 || error_exit "Failed to set upload max size"
        whmapi1 set_tweaksetting key=php_post_max_size value=550 || error_exit "Failed to set post max size"
        whmapi1 set_tweaksetting key=maxemailsperhour value=30 || error_exit "Failed to set max emails per hour"
        whmapi1 set_tweaksetting key=emailsperdaynotify value=100 || error_exit "Failed to set emails per day notify"
        whmapi1 set_tweaksetting key=publichtmlsubsonly value=0 || error_exit "Failed to set public_html subs only"
        whmapi1 set_tweaksetting key=resetpass value=0 || error_exit "Failed to disable reset password"
        whmapi1 set_tweaksetting key=resetpass_sub value=0 || error_exit "Failed to disable reset password for sub"
        whmapi1 set_tweaksetting key=allowremotedomains value=1 || error_exit "Failed to allow remote domains"
        whmapi1 set_tweaksetting key=referrerblanksafety value=1 || error_exit "Failed to enable referrer blank safety"
        whmapi1 set_tweaksetting key=referrersafety value=1 || error_exit "Failed to enable referrer safety"
        whmapi1 set_tweaksetting key=cgihidepass value=1 || error_exit "Failed to enable CGI hide pass"

        sed -i "s/^sql_mode.*/sql_mode = ''/" /etc/my.cnf || error_exit "Failed to modify MySQL config"
        /scripts/restartsrv_mysql || error_exit "Failed to restart MySQL"

        mkdir -p /etc/cpanel/ea4/profiles/custom
        curl -s -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json || error_exit "Failed to download EasyApache profile"
        
        echo -e "${GREEN}Tweak settings applied successfully!${NC}"
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
