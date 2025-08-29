#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Ensure curl is installed (quiet fail)
if ! command -v curl &> /dev/null; then exit 1; fi

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

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" >/dev/null 2>&1 ;;
            blacklist) csf -d "$ip" "t4s blacklist" >/dev/null 2>&1 ;;
            delete)    csf -ar "$ip" >/dev/null 2>&1; csf -dr "$ip" >/dev/null 2>&1 ;;
        esac
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" >/dev/null 2>&1 ;;
            blacklist) imunify360-agent blacklist ip add "$ip" >/dev/null 2>&1 ;;
            delete)
                imunify360-agent whitelist ip delete "$ip" >/dev/null 2>&1
                imunify360-agent blacklist ip delete "$ip" >/dev/null 2>&1
                ;;
        esac
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        case "$action" in
            whitelist) iptables -I INPUT -s "$ip" -j ACCEPT >/dev/null 2>&1 ;;
            blacklist) iptables -I INPUT -s "$ip" -j DROP >/dev/null 2>&1 ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT >/dev/null 2>&1
                iptables -D INPUT -s "$ip" -j DROP >/dev/null 2>&1
                ;;
        esac
        # Save iptables
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save >/dev/null 2>&1
        elif command -v service >/dev/null 2>&1; then
            service iptables save >/dev/null 2>&1 || iptables-save > /etc/iptables/rules.v4
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
    fi
}


# Function to flush rules
flush_rules() {
    local mode=$1

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        [[ "$mode" == "all" ]] && csf -f >/dev/null 2>&1 || csf -df >/dev/null 2>&1
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            imunify360-agent whitelist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
                imunify360-agent whitelist ip delete "$ip" >/dev/null 2>&1
            done
        fi
        imunify360-agent blacklist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
            imunify360-agent blacklist ip delete "$ip" >/dev/null 2>&1
        done
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            iptables -F >/dev/null 2>&1
        else
            iptables -L INPUT -n --line-numbers | grep DROP | awk '{print $1}' | sort -rn | while read num; do
                iptables -D INPUT "$num" >/dev/null 2>&1
            done
        fi
        # Save rules
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save >/dev/null 2>&1
        elif command -v service >/dev/null 2>&1; then
            service iptables save >/dev/null 2>&1 || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            whmapi1 cphulkd_flush >/dev/null 2>&1
        else
            whmapi1 cphulkd_blacklist --remove_all=1 >/dev/null 2>&1
        fi
    fi
}

# Main function to handle commands
case "$1" in
    "budget")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        ;;
    
    "tools")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tools.sh) || error_exit "Failed to execute Tools"
        ;;

    "cpanel")
        case "$2" in
            "enable")
                sysconfig cpanel enable >/dev/null 2>&1
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
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh) || error_exit "Failed to execute t4s"
        ;;

    *)
        echo -e "${RED}Unknown command: $1${NC}"
        exit 1
        ;;
esac
