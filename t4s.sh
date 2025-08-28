#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Spinner function for visual feedback
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ ERROR: curl is not installed. Please install curl and try again.${NC}"
    exit 1
fi

# Ensure we are running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠ Warning: This script requires root privileges. You may need to enter sudo passwords.${NC}"
fi

# Function to handle errors
error_exit() {
    echo -e "${RED}✗ ERROR: $1${NC}" >&2
    exit 1
}

# Function to resolve domain -> IP if needed
resolve_ip() {
    local target=$1
    if [[ "$target" =~ [a-zA-Z] ]]; then
        echo -e "${YELLOW}↳ Resolving domain $target...${NC}"
        local ip=$(dig +short "$target" | tail -n1)
        if [[ -z "$ip" ]]; then
            error_exit "Unable to resolve domain $target"
        fi
        echo -e "${GREEN}✓ Resolved $target to $ip${NC}"
        echo "$ip"
    else
        echo "$target"
    fi
}

# Function to handle whitelist/blacklist/delete
manage_ip() {
    local action=$1
    local target=$2
    local ip=$(resolve_ip "$target")

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} Processing ${action^} for IP: $ip ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Processing CSF...${NC}"
        case "$action" in
            whitelist)
                csf -a "$ip" "t4s whitelist" &
                spinner $!
                echo -e "${GREEN}✓ CSF: Added $ip to csf.allow${NC}"
                echo -e "${YELLOW}⚠ Deprecated: Use 'ip-list' command instead${NC}"
                ;;
            blacklist)
                csf -d "$ip" "t4s blacklist" &
                spinner $!
                echo -e "${GREEN}✓ CSF: Added $ip to csf.deny${NC}"
                ;;
            delete)
                csf -ar "$ip"; csf -dr "$ip" &
                spinner $!
                echo -e "${GREEN}✓ CSF: Removed $ip from csf.allow and csf.deny${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}⚠ CSF: Not installed, skipping...${NC}"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Processing Imunify360...${NC}"
        case "$action" in
            whitelist)
                imunify360-agent whitelist ip add "$ip" &
                spinner $!
                echo -e "${GREEN}✓ Imunify360: Whitelisted $ip${NC}"
                ;;
            blacklist)
                imunify360-agent blacklist ip add "$ip" &
                spinner $!
                echo -e "${GREEN}✓ Imunify360: Blacklisted $ip${NC}"
                ;;
            delete)
                imunify360-agent whitelist ip delete "$ip" &
                imunify360-agent blacklist ip delete "$ip" &
                spinner $!
                echo -e "${GREEN}✓ Imunify360: Removed $ip from whitelist and blacklist${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}⚠ Imunify360: Not installed, skipping...${NC}"
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Processing iptables...${NC}"
        case "$action" in
            whitelist)
                iptables -I INPUT -s "$ip" -j ACCEPT &
                spinner $!
                echo -e "${GREEN}✓ iptables: Added ACCEPT rule for $ip${NC}"
                ;;
            blacklist)
                iptables -I INPUT -s "$ip" -j DROP &
                spinner $!
                echo -e "${GREEN}✓ iptables: Added DROP rule for $ip${NC}"
                ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
                iptables -D INPUT -s "$ip" -j DROP 2>/dev/null &
                spinner $!
                echo -e "${GREEN}✓ iptables: Removed rules for $ip${NC}"
                ;;
        esac
        # Save iptables
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save &
            spinner $!
            echo -e "${GREEN}✓ iptables: Rules saved${NC}"
        elif command -v service >/dev/null 2>&1; then
            service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4 &
            spinner $!
            echo -e "${GREEN}✓ iptables: Rules saved${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ iptables: Not installed, skipping...${NC}"
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Processing cPHulk...${NC}"
        case "$action" in
            whitelist)
                whmapi1 cphulkd_whitelist_add ip="$ip" >/dev/null &
                spinner $!
                echo -e "${GREEN}✓ cPHulk: Whitelisted $ip${NC}"
                ;;
            blacklist)
                whmapi1 cphulkd_blacklist_add ip="$ip" >/dev/null &
                spinner $!
                echo -e "${GREEN}✓ cPHulk: Blacklisted $ip${NC}"
                ;;
            delete)
                whmapi1 cphulkd_whitelist_delete ip="$ip" >/dev/null
                whmapi1 cphulkd_blacklist_delete ip="$ip" >/dev/null &
                spinner $!
                echo -e "${GREEN}✓ cPHulk: Removed $ip from whitelist and blacklist${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}⚠ cPHulk: Not installed, skipping...${NC}"
    fi

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ ${action^} completed successfully for $ip${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

# Function to flush rules
flush_rules() {
    local mode=$1

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} Flushing rules ($mode)...${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Flushing CSF...${NC}"
        [[ "$mode" == "all" ]] && csf -f || csf -df &
        spinner $!
        echo -e "${GREEN}✓ CSF: Rules flushed ($mode)${NC}"
    else
        echo -e "${YELLOW}⚠ CSF: Not installed, skipping...${NC}"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Flushing Imunify360...${NC}"
        if [[ "$mode" == "all" ]]; then
            imunify360-agent whitelist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
                imunify360-agent whitelist ip delete "$ip" &
                spinner $!
            done
        fi
        imunify360-agent blacklist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
            imunify360-agent blacklist ip delete "$ip" &
            spinner $!
        done
        echo -e "${GREEN}✓ Imunify360: Rules flushed ($mode)${NC}"
    else
        echo -e "${YELLOW}⚠ Imunify360: Not installed, skipping...${NC}"
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Flushing iptables...${NC}"
        if [[ "$mode" == "all" ]]; then
            iptables -F &
            spinner $!
        else
            iptables -L INPUT -n --line-numbers | grep DROP | awk '{print $1}' | sort -rn | while read num; do
                iptables -D INPUT "$num" &
                spinner $!
            done
        fi
        # Save rules
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save &
            spinner $!
            echo -e "${GREEN}✓ iptables: Rules saved${NC}"
        elif command -v service >/dev/null 2>&1; then
            service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4 &
            spinner $!
            echo -e "${GREEN}✓ iptables: Rules saved${NC}"
        fi
        echo -e "${GREEN}✓ iptables: Rules flushed ($mode)${NC}"
    else
        echo -e "${YELLOW}⚠ iptables: Not installed, skipping...${NC}"
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        echo -e "${YELLOW}↳ Flushing cPHulk...${NC}"
        if [[ "$mode" == "all" ]]; then
            whmapi1 cphulkd_flush &
            spinner $!
        else
            whmapi1 cphulkd_blacklist --remove_all=1 &
            spinner $!
        fi
        echo -e "${GREEN}✓ cPHulk: Rules flushed ($mode)${NC}"
    else
        echo -e "${YELLOW}⚠ cPHulk: Not installed, skipping...${NC}"
    fi

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Flush ($mode) completed successfully${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
}

# Main function to handle commands
case "$1" in
    "budget")
        echo -e "${GREEN}✓ Launching Budget Licensing System...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        ;;

    "tools")
        echo -e "${GREEN}✓ Launching Tools...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tools.sh) || error_exit "Failed to execute Tools"
        ;;

    "cpanel")
        case "$2" in
            "enable")
                echo -e "${YELLOW}↳ Enabling cPanel...${NC}"
                sysconfig cpanel enable &
                spinner $!
                echo -e "${GREEN}✓ cPanel: Enabled and started${NC}"
                ;;
            *)
                error_exit "Unknown cPanel command: $2"
                ;;
        esac
        ;;

    "tweak")
        echo -e "${GREEN}✓ Launching Tweak Settings...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
        ;;

    "update")
        echo -e "${GREEN}✓ Updating script...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/init-t4s) || error_exit "Failed to update the script"
        ;;

    "whitelist"|"blacklist"|"delete")
        if [[ -z "$2" ]]; then
            error_exit "Usage: $0 $1 <ip/domain/ip-cidr>"
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
        echo -e "${GREEN}✓ Fetching the latest script version...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh) || error_exit "Failed to execute t4s"
        ;;

    *)
        error_exit "Unknown command: $1"
        ;;
esac