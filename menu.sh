#!/bin/bash

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color


# Constants
SCRIPT_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/main/theme4sell.sh"
VERSION_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/main/version.sh"
RC_LICENSE_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/main/rc-licensing.sh"
LOG_FILE="/var/log/t4s_menu.log"
VERSION="2.3.0"
T4S_PATH="/usr/local/bin/t4s"

# Spinner function for progress indication
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Error exit function
error_exit() {
    echo -e "${RED}ERROR: $1${NC}"
    log "ERROR: $1"
    exit 1
}

# Check for dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    for cmd in curl sed awk grep; do
        if ! command -v "$cmd" &>/dev/null; then
            error_exit "$cmd is not installed. Please install it and try again."
        fi
    done
    log "Dependencies verified"
}

# Load version information
load_version() {
    echo -e "${YELLOW}Loading version information...${NC}"
    if ! source <(curl -fsSL "$VERSION_URL" 2>/dev/null) &>/dev/null; then
        error_exit "Failed to load version information from $VERSION_URL"
    fi
    log "Version information loaded: MENU_VERSION=$MENU_VERSION, T4S_VERSION=$T4S_VERSION, INI_VERSION=$INI_VERSION"
}

# Display menu
display_menu() {
    clear
    echo -e "${BLUE}=============================================${NC}"
    echo -e "${BLUE}        Theme4Sell Configuration Menu        ${NC}"
    echo -e "${BLUE}             Version $VERSION               ${NC}"
    echo -e "${BLUE}=============================================${NC}"
    echo -e ""
    echo -e "${RED}*************** ⚠ WARNING ⚠ ***************${NC}"
    echo -e "${YELLOW}Complete Server Basic Config before installation!${NC}"
    echo -e "${YELLOW}Select option 1 for server preparation.${NC}"
    echo -e "${RED}***************************************${NC}"
    echo -e ""
    echo -e "${YELLOW}1 - Server Basic Config (Before Installation)${NC} ${RED}[Required]${NC}"
    echo -e "2 - RC License Script"
    echo -e "3 - Syslic License Script"
    echo -e "4 - Official Installation Scripts"
    echo -e "5 - Auto Config"
    echo -e "6 - Whitelist an IP"
    echo -e "7 - Blacklist an IP"
    echo -e "8 - DNS Flush"
    echo -e "9 - Allow Our ip's"
    echo -e "0 - Exit"
    echo -e ""
}

# Validate user input
validate_input() {
    local input=$1
    if ! [[ "$input" =~ ^[0-9]$ ]]; then
        error_exit "Invalid option! Please select 0-9."
    fi
}

# Check sudo privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Warning: This script requires root privileges. You may need to enter sudo passwords.${NC}"
        log "Running with non-root privileges"
    fi
}

# Initialize log file
mkdir -p "$(dirname "$LOG_FILE")" &>/dev/null
log "Starting Theme4Sell Configuration Menu v$VERSION"

# Main script
check_dependencies
check_sudo
load_version

# Main loop
while true; do
    display_menu
    read -p "Enter your choice (0-9): " choice
    validate_input "$choice"
    log "User selected option $choice"

    case $choice in
        1)
            echo -e "${YELLOW}Configuring basic server settings...${NC}"
            read -p "Enter the server IP: " server_ip
            read -p "Enter the hostname: " hostname
            read -p "Enter the hostname prefix: " hostname_prefix

            # Validate inputs
            if [[ -z "$server_ip" || -z "$hostname" || -z "$hostname_prefix" ]]; then
                error_exit "Server IP, hostname, and prefix cannot be empty."
            fi

            echo -e "${YELLOW}Updating hosts file...${NC}"
            echo "$server_ip $hostname $hostname_prefix" | tee -a /etc/hosts &>/dev/null &
            spinner $!
            log "Updated /etc/hosts with $server_ip $hostname $hostname_prefix"

            echo -e "${YELLOW}Configuring DNS...${NC}"
            echo "nameserver 8.8.8.8" | tee /etc/resolv.conf &>/dev/null
            echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf &>/dev/null &
            spinner $!
            log "Configured DNS with Google nameservers"

            echo -e "${YELLOW}Installing AlmaLinux release...${NC}"
            yum install almalinux-release -y &>/dev/null &
            spinner $!
            log "Installed AlmaLinux release"

            echo -e "${YELLOW}Installing nano...${NC}"
            yum install nano -y &>/dev/null &
            spinner $!
            log "Installed nano"

            echo -e "${YELLOW}Setting timezone to Asia/Dhaka...${NC}"
            timedatectl set-timezone Asia/Dhaka &>/dev/null &
            spinner $!
            log "Set timezone to Asia/Dhaka"

            echo -e "${YELLOW}Updating packages...${NC}"
            yum update -y &>/dev/null &
            spinner $!
            log "Updated system packages"

            echo -e "${YELLOW}Installing curl and perl...${NC}"
            yum install perl curl -y &>/dev/null &
            spinner $!
            log "Installed curl and perl"

            echo -e "${YELLOW}Configuring firewall for WHM...${NC}"
            iptables-save > ~/firewall.rules &>/dev/null
            systemctl stop firewalld.service &>/dev/null
            systemctl disable firewalld.service &>/dev/null &
            spinner $!
            log "Disabled firewalld and saved iptables"

            clear
            echo -e "${RED}Server configuration complete. Reboot required.${NC}"
            echo -e "${GREEN}Press Ctrl+C to skip reboot, or wait 30 seconds.${NC}"
            log "Prompting for system reboot"
            sleep 30
            echo -e "${GREEN}After reboot, run 't4s' to continue.${NC}"
            echo -e "${RED}Rebooting...${NC}"
            log "Initiating system reboot"
            reboot now
            ;;
        2)
            echo -e "${YELLOW}Running RC License Script...${NC}"
            if bash <(curl -fsSL "$RC_LICENSE_URL") &>/dev/null & then
                pid=$!
                spinner $pid
                wait $pid
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}RC License Script executed successfully${NC}"
                    log "RC License Script executed successfully from $RC_LICENSE_URL"
                else
                    error_exit "Failed to execute RC License Script"
                fi
            else
                error_exit "Failed to fetch or run RC License Script from $RC_LICENSE_URL"
            fi
            sleep 3
            bash "$0" # Restart script
            ;;
        3)
            echo -e "${YELLOW}Running Syslic License Script...${NC}"
            echo -e "${GREEN}This feature is under development.${NC}"
            log "Syslic License Script requested (under development)"
            sleep 3
            bash "$0" # Restart script
            ;;
        4)
            echo -e "${YELLOW}Running Official Installation Scripts...${NC}"
            echo -e "${GREEN}This feature is under development.${NC}"
            log "Official Installation Scripts requested (under development)"
            sleep 3
            bash "$0" # Restart script
            ;;
        5)
            echo -e "${YELLOW}Running Auto Config...${NC}"
            echo -e "${GREEN}This feature is under development.${NC}"
            log "Auto Config requested (under development)"
            sleep 3
            bash "$0" # Restart script
            ;;
        6)
            echo -e "${YELLOW}Whitelisting an IP...${NC}"
            read -p "Enter the IP address to whitelist: " ip_address
            if [[ ! "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                error_exit "Invalid IP address format."
            fi
            echo -e "${YELLOW}Adding $ip_address to whitelist...${NC}"
            # Placeholder for iptables or firewall-cmd command
            echo -e "${GREEN}IP $ip_address whitelisted (placeholder).${NC}"
            log "Whitelisted IP $ip_address (placeholder)"
            sleep 3
            bash "$0" # Restart script
            ;;
        7)
            echo -e "${YELLOW}Blacklisting an IP...${NC}"
            read -p "Enter the IP address to blacklist: " ip_address
            if [[ ! "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                error_exit "Invalid IP address format."
            fi
            echo -e "${YELLOW}Adding $ip_address to blacklist...${NC}"
            # Placeholder for iptables or firewall-cmd command
            echo -e "${GREEN}IP $ip_address blacklisted (placeholder).${NC}"
            log "Blacklisted IP $ip_address (placeholder)"
            sleep 3
            bash "$0" # Restart script
            ;;
        8)
            echo -e "${YELLOW}Flushing DNS cache...${NC}"
            systemctl restart named &>/dev/null &
            spinner $!
                /scripts/configure_firewall_for_cpanel
                /usr/local/cpanel/cpsrvd
                iptables -P INPUT ACCEPT
                iptables -P FORWARD ACCEPT
                iptables -P OUTPUT ACCEPT
                iptables -t nat -F
                iptables -t mangle -F
                /usr/sbin/iptables -F
                /usr/sbin/iptables -X
            log "DNS cache flushed"
            sleep 3
            bash "$0" # Restart script
            ;;
        9)
            echo -e "${YELLOW}Performing hard DNS flush...${NC}"
            # Bind/named cache
            systemctl restart named &>/dev/null
            rm -rf /var/cache/named/* &>/dev/null &
            spinner $!

            # PowerDNS Recursor cache
            if command -v rec_control &>/dev/null; then
                echo -e "${YELLOW}Clearing PowerDNS Recursor cache...${NC}"
                rec_control wipe-cache &>/dev/null || systemctl reload pdns-recursor &>/dev/null
            elif systemctl list-units --type=service | grep -qE '^pdns-recursor'; then
                systemctl reload pdns-recursor &>/dev/null
            fi

            # PowerDNS Authoritative cache
            if command -v pdns_control &>/dev/null; then
                echo -e "${YELLOW}Clearing PowerDNS Authoritative cache...${NC}"
                pdns_control wipe-cache &>/dev/null || pdns_control purge &>/dev/null || systemctl reload pdns &>/dev/null
            elif systemctl list-units --type=service | grep -qE '^pdns'; then
                systemctl reload pdns &>/dev/null
            fi

            # dnsdist cache
            if command -v dnsdist &>/dev/null; then
                echo -e "${YELLOW}Clearing dnsdist cache...${NC}"
                dnsdist -e "clearCache()" &>/dev/null || systemctl reload dnsdist &>/dev/null
            elif systemctl list-units --type=service | grep -qE '^dnsdist'; then
                systemctl reload dnsdist &>/dev/null
            fi

            echo -e "${GREEN}Hard DNS flush completed successfully.${NC}"
            log "Hard DNS flush completed (named + PowerDNS caches)"
            sleep 3
            bash "$0" # Restart script
            ;;
        0)
            clear
            echo -e "${GREEN}Thank you for using Theme4Sell v$VERSION${NC}"
            echo -e "${BLUE}Logs are available at: $LOG_FILE${NC}"
            log "Exiting Theme4Sell Configuration Menu"
            exit 0
            ;;
    esac
done
