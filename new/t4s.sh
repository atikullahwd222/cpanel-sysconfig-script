#!/bin/bash
# Colors for output
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

HOSTNAME=$(hostname)

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "ERROR: curl is not installed. Please install curl and try again."
    exit 1
fi

# Warn if not root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Warning: You are not running as root. Some operations may fail.${NC}"
fi

# Error handler
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Resolve hostname to IP
resolve_ip() {
    local target="$1"
    if [[ "$target" =~ [a-zA-Z] ]]; then
        local ip=$(dig +short "$target" | tail -n1)
        [[ -z "$ip" ]] && error_exit "Unable to resolve $target"
        echo "$ip"
    else
        echo "$target"
    fi
}

# Validate IPv4/IPv6 format (basic)
validate_ip() {
    local ip="$1"
    if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$ip" =~ ^([0-9a-fA-F:]+)$ ]]; then
        error_exit "Invalid IP: $ip"
    fi
}

# Manage IP: whitelist / blacklist / delete
manage_ip() {
    local action="$1"
    local target="$2"
    local ip
    ip=$(resolve_ip "$target")
    validate_ip "$ip"

    echo -e "${YELLOW}Processing $action for $ip...${NC}"

    # --- CSF ---
    if command -v csf &>/dev/null; then
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" &>/dev/null ;;
            blacklist) csf -d "$ip" "t4s blacklist" &>/dev/null ;;
            delete)    csf -ar "$ip" &>/dev/null; csf -dr "$ip" &>/dev/null ;;
        esac
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent &>/dev/null; then
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" &>/dev/null ;;
            blacklist) imunify360-agent blacklist ip add "$ip" &>/dev/null ;;
            delete)
                imunify360-agent whitelist ip delete "$ip" &>/dev/null
                imunify360-agent blacklist ip delete "$ip" &>/dev/null
                ;;
        esac
    fi

    # --- iptables ---
    if command -v iptables &>/dev/null; then
        case "$action" in
            whitelist) iptables -I INPUT -s "$ip" -j ACCEPT &>/dev/null ;;
            blacklist) iptables -I INPUT -s "$ip" -j DROP &>/dev/null ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT &>/dev/null
                iptables -D INPUT -s "$ip" -j DROP &>/dev/null
                ;;
        esac
        # Save iptables
        if command -v netfilter-persistent &>/dev/null; then
            netfilter-persistent save &>/dev/null
        elif command -v service &>/dev/null; then
            service iptables save &>/dev/null || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # --- cPHulk ---
    if command -v whmapi1 &>/dev/null; then
        case "$action" in
            whitelist) /usr/local/cpanel/scripts/cphulkdwhitelist "$ip" &>/dev/null ;;
            blacklist) /usr/local/cpanel/scripts/cphulkdblacklist "$ip" &>/dev/null ;;
            delete)
                /usr/local/cpanel/scripts/cphulkdwhitelist "$ip" &>/dev/null
                ;;
        esac
    fi

    echo -e "${GREEN}✅ $action complete for $ip${NC}"
}

# Flush manually added rules
flush_rules() {
    echo -e "${YELLOW}Flushing all t4s-managed IPs...${NC}"

    # CSF
    if command -v csf &>/dev/null; then
        grep -E "t4s whitelist|t4s blacklist" /etc/csf/csf.allow /etc/csf/csf.deny 2>/dev/null \
            | awk '{print $1}' | sort -u | while read ip; do
                csf -ar "$ip" &>/dev/null
                csf -dr "$ip" &>/dev/null
            done
        csf -tf &>/dev/null
    fi

    # Imunify360
    if command -v imunify360-agent &>/dev/null; then
        imunify360-agent whitelist ip list 2>/dev/null | awk '{print $1}' | sort -u | while read ip; do
            imunify360-agent whitelist ip delete "$ip" &>/dev/null
        done
        imunify360-agent blacklist ip list 2>/dev/null | awk '{print $1}' | sort -u | while read ip; do
            imunify360-agent blacklist ip delete "$ip" &>/dev/null
        done
    fi

    # iptables
    if command -v iptables &>/dev/null; then
        iptables -L INPUT -n --line-numbers | grep -E 'ACCEPT|DROP' | awk '{print $1 " " $4 " " $5}' \
            | while read num ip action; do
                iptables -D INPUT -s "$ip" -j "$action" 2>/dev/null
            done
        if command -v netfilter-persistent &>/dev/null; then
            netfilter-persistent save &>/dev/null
        elif command -v service &>/dev/null; then
            service iptables save &>/dev/null || iptables-save > /etc/iptables/rules.v4
        fi
    fi

    # cPHulk
    if command -v whmapi1 &>/dev/null; then
        whmapi1 cphulkd_whitelist_list 2>/dev/null | grep -Eo '([0-9]+\.){3}[0-9]+' | sort -u | while read ip; do
            whmapi1 cphulkd_whitelist_delete ip="$ip" &>/dev/null
        done
        whmapi1 cphulkd_blacklist_list 2>/dev/null | grep -Eo '([0-9]+\.){3}[0-9]+' | sort -u | while read ip; do
            whmapi1 cphulkd_blacklist_delete ip="$ip" &>/dev/null
        done
    fi

    echo -e "${GREEN}✅ Flush complete.${NC}"
}

# --- Main ---
case "$1" in
    "budget")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        ;;
    "tools")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/scripts/tools.sh) || error_exit "Failed to execute Tools"
        ;;
    "tweak")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
        ;;
    "update")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/init.sh) || error_exit "Failed to update the script"
        ;;
    "whitelist"|"blacklist"|"delete")
        [[ -z "$2" ]] && error_exit "Usage: $0 $1 <ip/domain/ip-cidr>"
        manage_ip "$1" "$2"
        ;;
    "flush"|"flush-all"|"flush_all"|"flushall"|"flush all")
        flush_rules
        ;;
    "")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/main_menu.sh) || error_exit "Failed to execute t4s"
        ;;
    *)
        error_exit "Unknown command: $1"
        ;;
esac
