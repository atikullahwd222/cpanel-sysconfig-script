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
    local action=$1   # whitelist, blacklist, delete
    local target=$2
    local ip=$(resolve_ip "$target")

    echo -e "${YELLOW}Processing $action for $ip...${NC}"

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" ;;
            blacklist) csf -d "$ip" "t4s blacklist" ;;
            delete)    csf -ar "$ip"; csf -dr "$ip" ;;
        esac
        echo -e " ${GREEN}${action^}ing $ip in CSF done......${NC}"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" ;;
            blacklist) imunify360-agent blacklist ip add "$ip" ;;
            delete)
                imunify360-agent whitelist ip delete "$ip"
                imunify360-agent blacklist ip delete "$ip"
                ;;
        esac
        echo -e " ${GREEN}${action^}ing $ip in Imunify360 done......${NC}"
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        case "$action" in
            whitelist) iptables -I INPUT -s "$ip" -j ACCEPT ;;
            blacklist) iptables -I INPUT -s "$ip" -j DROP ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
                iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
                ;;
        esac
        echo -e " ${GREEN}${action^}ing $ip in iptables done......${NC}"
        # Save iptables
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save
        elif command -v service >/dev/null 2>&1; then
            service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        case "$action" in
            whitelist) whmapi1 cphulkd_whitelist_add ip="$ip" >/dev/null ;;
            blacklist) whmapi1 cphulkd_blacklist_add ip="$ip" >/dev/null ;;
            delete)
                whmapi1 cphulkd_whitelist_delete ip="$ip" >/dev/null
                whmapi1 cphulkd_blacklist_delete ip="$ip" >/dev/null
                ;;
        esac
        echo -e " ${GREEN}${action^}ing $ip in CPhulk done......${NC}"
    fi

    echo -e "${GREEN}✅ $action complete for $ip${NC}"
}


# Function to flush rules
flush_rules() {
    local mode=$1

    echo -e "${YELLOW}Flushing rules ($mode)...${NC}"

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        [[ "$mode" == "all" ]] && csf -f || csf -df
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            imunify360-agent whitelist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
                imunify360-agent whitelist ip delete "$ip"
            done
        fi
        imunify360-agent blacklist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
            imunify360-agent blacklist ip delete "$ip"
        done
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            iptables -F
        else
            iptables -L INPUT -n --line-numbers | grep DROP | awk '{print $1}' | sort -rn | while read num; do
                iptables -D INPUT "$num"
            done
        fi
        # Save rules
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save
        elif command -v service >/dev/null 2>&1; then
            service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            whmapi1 cphulkd_flush
        else
            whmapi1 cphulkd_blacklist --remove_all=1
        fi
    fi

    echo -e "${GREEN}✅ Flush ($mode) complete${NC}"
}

# Main function to handle commands
case "$1" in
    "budget")
        echo -e "${GREEN}You selected Budget Licensing System.${NC}"
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

    "whitelist"|"blacklist"|"delete")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Usage: $0 $1 <ip/domain/ip-cidr>${NC}"
            exit 1
        fi
        manage_ip "$1" "$2"
        ;;

    "flush")
        flush_rules "blacklist"
        ;;

    "flush-all"|"flush_all"|"flushall"|"flush all")
        flush_rules "all"
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
