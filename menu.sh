#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

source <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/version.sh)

# Ensure curl is installed
if ! command -v curl &> /dev/null; then exit 1; fi

# Create directory for t4s if it does not exist
mkdir -p /usr/local/bin &>/dev/null

clear
Theme4Sell_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh"

# Interactive menu (prettified)
echo -e "${GREEN}+--------------------------------------------------------------+${NC}"
echo -e "${GREEN}|${NC}    ____  __  __   _____            __                ${GREEN}|${NC}"
echo -e "${GREEN}|${NC}   / __ )/ / / /  / ___/__  _______/ /____  ____ ___  ${GREEN}|${NC}"
echo -e "${GREEN}|${NC}  / __  / /_/ /   \\__ \\/ / / / ___/ __/ _ \\/ __ \\`__ \\ ${GREEN}|${NC}"
echo -e "${GREEN}|${NC} / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / / ${GREEN}|${NC}"
echo -e "${GREEN}|${NC}/_____/_/_/_/_  /____/\\__, /____/\\__/\\___/_/ /_/ /_/  ${GREEN}|${NC}"
echo -e "${GREEN}|${NC}                     /____/                    v$MENU_VERSION  ${GREEN}|${NC}"
echo -e "${GREEN}+--------------------------------------------------------------+${NC}"
echo -e "${YELLOW}| 1 |${NC} Do Basic Config (prepare server for WHM) ${RED}!Important${NC}"
echo -e "${YELLOW}| 2 |${NC} Tools                               v$T4S_VERSION"
echo -e "${YELLOW}| 3 |${NC} Change SSH port"
echo -e "${YELLOW}| 4 |${NC} Set PHP ini                        v$INI_VERSION"
echo -e "${YELLOW}| 5 |${NC} Install WHM and Tweaks"
echo -e "${GREEN}+--------------------------------------------------------------+${NC}"

read -p "Select [0-5] > " choice

if [[ "$choice" == "1" ]]; then
    read -p "Enter the server IP: " server_ip
    read -p "Enter the hostname: " hostname
    read -p "Enter the hostname prefix: " hostname_prefix

    echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

    yum install almalinux-release -y &>/dev/null

    yum install nano -y &>/dev/null
    
    timedatectl set-timezone Asia/Dhaka &>/dev/null

    yum update -y &>/dev/null

    yum install perl curl -y &>/dev/null

    iptables-save > ~/firewall.rules &>/dev/null
    systemctl stop firewalld.service &>/dev/null
    systemctl disable firewalld.service &>/dev/null

    timedatectl set-timezone Asia/Dhaka &>/dev/null

    clear

    echo -e "${YELLOW}Rebooting to apply changes...${NC}"

    reboot now

elif [[ "$choice" == "2" ]]; then
    bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tools.sh) || error_exit "Failed to execute Theme4Sell"

elif [[ "$choice" == "3" ]]; then
    current_port=$(grep -E "^#?Port" /etc/ssh/sshd_config | awk '{print $2}' | head -n 1)
    
    if [[ -z "$current_port" ]]; then
        current_port=22
    fi
    
    echo "Current SSH port: $current_port"

    read -p "Enter the new SSH port number: " new_port
    
    sudo sed -i "s/^#\?Port $current_port/Port $new_port/g" /etc/ssh/sshd_config && sudo systemctl restart sshd
    
    t4s

elif [[ "$choice" == "4" ]]; then
    echo -e "${GREEN}Applying PHP.ini tweaks to all PHP versions...${NC}"

    php_ini_files=$(find /opt/alt/ /opt/cpanel/ea-php*/root/etc/ /opt/alt/php-internal/ -type f -name php.ini 2>/dev/null)

    if [[ -z "$php_ini_files" ]]; then
        echo -e "${RED}No php.ini files found! Skipping...${NC}"
    else
        for file in $php_ini_files; do
            sed -i 's/^\s*;\?\s*allow_url_fopen\s*=.*/allow_url_fopen = On/' "$file"
            sed -i 's/^\s*;\?\s*max_execution_time\s*=.*/max_execution_time = 30000/' "$file"
            sed -i 's/^\s*;\?\s*max_input_time\s*=.*/max_input_time = 60000/' "$file"
            sed -i 's/^\s*;\?\s*max_input_vars\s*=.*/max_input_vars = 10000/' "$file"
            sed -i 's/^\s*;\?\s*memory_limit\s*=.*/memory_limit = 1024M/' "$file"
            sed -i 's/^\s*;\?\s*post_max_size\s*=.*/post_max_size = 1024M/' "$file"
            sed -i 's/^\s*;\?\s*session.gc_maxlifetime\s*=.*/session.gc_maxlifetime = 14400/' "$file"
            sed -i 's/^\s*;\?\s*upload_max_filesize\s*=.*/upload_max_filesize = 1024M/' "$file"
            sed -i 's/^\s*;\?\s*zlib.output_compression\s*=.*/zlib.output_compression = On/' "$file"
            sed -i 's/^\s*;\?\s*error_reporting\s*=.*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_STRICT/' "$file"
            sed -i 's|^\s*;\?\s*date.timezone\s*=.*|date.timezone = "Asia/Dhaka"|' "$file"

            echo -e "${GREEN}Updated $file${NC}"
        done
    fi

    systemctl restart httpd >/dev/null &>/dev/null

    for service in $(systemctl list-units --type=service --plain --no-legend | awk '{print $1}' | grep php-fpm); do
        systemctl restart "$service" >/dev/null &>/dev/null
    done

    echo -e "${GREEN}PHP.ini tweaks applied.${NC}"

elif [[ "$choice" == "5" ]]; then
    echo -e "${YELLOW}Coming soon.${NC}"
    t4s

elif [[ "$choice" == "0" ]]; then
    echo -e "${GREEN}Exiting...${NC}"
    exit 0
else
    echo -e "${RED}Invalid option! Please select 1-4.${NC}"
    exit 0
fi