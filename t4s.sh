#!/bin/bash
# Colors for output (minimal use)
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

# Get hostname for prompt
HOSTNAME=$(hostname)

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
    echo -e "ERROR: $1" >&2
    exit 1
}

# Function to resolve domain -> IP if needed
resolve_ip() {
    local target=$1
    if [[ "$target" =~ [a-zA-Z] ]]; then
        local ip=$(dig +short "$target" | tail -n1)
        if [[ -z "$ip" ]]; then
            echo -e "ERROR: Unable to resolve $target"
            exit 1
        fi
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

    # Print deprecated warning for whitelist
    if [[ "$action" == "whitelist" ]]; then
        echo -e "${YELLOW}!! Deprecated cli call, use \`ip-list\` command instead. !!${NC}"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" >/dev/null ;;
            blacklist) imunify360-agent blacklist ip add "$ip" >/dev/null ;;
            delete)
                imunify360-agent whitelist ip delete "$ip" >/dev/null
                imunify360-agent blacklist ip delete "$ip" >/dev/null
                ;;
        esac
        echo -e "${action^}ing $ip in Imunify360 done......"
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
        echo -e "${action^}ing $ip in CPhulk done......"
    fi

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" >/dev/null ;;
            blacklist) csf -d "$ip" "t4s blacklist" >/dev/null ;;
            delete)    csf -ar "$ip" >/dev/null; csf -dr "$ip" >/dev/null ;;
        esac
        echo -e "${action^}ing $ip in CSF done......"
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        case "$action" in
            whitelist) iptables -I INPUT -s "$ip" -j ACCEPT >/dev/null ;;
            blacklist) iptables -I INPUT -s "$ip" -j DROP >/dev/null ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
                iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
                ;;
        esac
        # Save iptables
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save >/dev/null
        elif command -v service >/dev/null 2>&1; then
            service iptables save >/dev/null 2>&1 || iptables-save > /etc/iptables/rules.v4
        fi
        echo -e "${action^}ing $ip in iptables done......"
    fi

    # Print final prompt
    echo -e "[root@$HOSTNAME ~]#"
}

# Function to flush rules
flush_rules() {
    local mode=$1

    # --- CSF ---
    if command -v csf >/dev/null 2>&1; then
        [[ "$mode" == "all" ]] && csf -f >/dev/null || csf -df >/dev/null
        echo -e "Flushing CSF ($mode) done......"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            imunify360-agent whitelist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
                imunify360-agent whitelist ip delete "$ip" >/dev/null
            done
        fi
        imunify360-agent blacklist ip list | awk '{print $1}' | grep -Eo '([0-9]+\.){3}[0-9]+' | while read ip; do
            imunify360-agent blacklist ip delete "$ip" >/dev/null
        done
        echo -e "Flushing Imunify360 ($mode) done......"
    fi

    # --- iptables ---
    if command -v iptables >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            iptables -F >/dev/null
        else
            iptables -L INPUT -n --line-numbers | grep DROP | awk '{print $1}' | sort -rn | while read num; do
                iptables -D INPUT "$num" >/dev/null
            done
        fi
        # Save rules
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save >/dev/null
        elif command -v service >/dev/null 2>&1; then
            service iptables save >/dev/null 2>&1 || iptables-save > /etc/iptables/rules.v4
        fi
        echo -e "Flushing iptables ($mode) done......"
    fi

    # --- cPHulk ---
    if command -v whmapi1 >/dev/null 2>&1; then
        if [[ "$mode" == "all" ]]; then
            whmapi1 cphulkd_flush >/dev/null
        else
            whmapi1 cphulkd_blacklist --remove_all=1 >/dev/null
        fi
        echo -e "Flushing cPHulk ($mode) done......"
    fi

    # Print final prompt
    echo -e "[root@$HOSTNAME ~]#"
}

# Main function to handle commands
case "$1" in
    "budget")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Theme4Sell"
        echo -e "[root@$HOSTNAME ~]#"
        ;;

    "tools")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tools.sh) || error_exit "Failed to execute Tools"
        echo -e "[root@$HOSTNAME ~]#"
        ;;

    "cpanel")
        case "$2" in
            "enable")
                sysconfig cpanel enable >/dev/null
                echo -e "cPanel has been enabled and started......"
                echo -e "[root@$HOSTNAME ~]#"
                ;;
            *)
                error_exit "Unknown cPanel command: $2"
                ;;
        esac
        ;;

    "tweak")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/tweak.sh) || error_exit "Failed to execute Tweak Settings"
        echo -e "[root@$HOSTNAME ~]#"
        ;;

    "update")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/init-t4s) || error_exit "Failed to update the script"
        echo -e "[root@$HOSTNAME ~]#"
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
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh) || error_exit "Failed to execute t4s"
        echo -e "[root@$HOSTNAME ~]#"
        ;;

    *)
        error_exit "Unknown command: $1"
        ;;
esac