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

# Function to resolve domain -> IP if needed
resolve_ip() {
    local target=$1
    if [[ "$target" =~ [a-zA-Z] ]]; then
        local ip=$(dig +short "$target" | tail -n1)
        if [[ -z "$ip" ]]; then
            echo -e "${RED}ERROR: Unable to resolve $target${NC}"
            exit 1
        fi
        echo "$ip"
    else
        echo "$target"
    fi
}

# Function to handle whitelist/blacklist
manage_ip() {
    local action=$1   # whitelist, blacklist, unwhitelist, unblacklist
    local target=$2
    local ip=$(resolve_ip "$target")

    echo -e "${GREEN}Processing $action for $ip...${NC}"

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" ;;
            blacklist) csf -d "$ip" "t4s blacklist" ;;
            unwhitelist) csf -ar "$ip" ;;
            unblacklist) csf -dr "$ip" ;;
        esac
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" ;;
            blacklist) imunify360-agent blacklist ip add "$ip" ;;
            unwhitelist) imunify360-agent whitelist ip delete "$ip" ;;
            unblacklist) imunify360-agent blacklist ip delete "$ip" ;;
        esac
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        case "$action" in
            whitelist)
                iptables -I INPUT -s "$ip" -j ACCEPT
                ;;
            blacklist)
                iptables -I INPUT -s "$ip" -j DROP
                ;;
            unwhitelist)
                iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
                ;;
            unblacklist)
                iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
                ;;
        esac
        # Save iptables (depends on OS)
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save
        elif command -v service >/dev/null 2>&1; then
            service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        case "$action" in
            whitelist) whmapi1 cphulkd_whitelist_add ip="$ip" ;;
            blacklist) whmapi1 cphulkd_blacklist_add ip="$ip" ;;
            unwhitelist) whmapi1 cphulkd_whitelist_delete ip="$ip" ;;
            unblacklist) whmapi1 cphulkd_blacklist_delete ip="$ip" ;;
        esac
    fi

    echo -e "${GREEN}✅ $action complete for $ip${NC}"
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
    
    "tools")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tools.sh) || error_exit "Failed to execute Tools"
        ;;

    "cpanel")
        case "$2" in
            "enable")
                sysconfig cpanel enable
                echo -e "${GREEN}cPanel has been enabled and started.${NC}"
                ;;
            *)
                echo -e "${RED}Unknown cPanel command: $2${NC}"
                exit 1
                ;;
        esac
        ;;

    "tweak")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
        ;;

    "update")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/init-t4s) || error_exit "Failed to Update the script"
        ;;

    "whitelist"|"blacklist"|"unwhitelist"|"unblacklist")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Usage: $0 $1 <ip/domain/ip-cidr>${NC}"
            exit 1
        fi
        manage_ip "$1" "$2"
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
