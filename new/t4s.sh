#!/bin/bash
# Colors for output
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
LOCAL_SCRIPT_VERSION="2.1.1"
HOSTNAME=$(hostname)
SCRIPT_URI="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/scripts"

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

    echo -e "${YELLOW}Processing $action for ${GREEN}$ip${NC}...${NC}"

    # --- CSF ---
    if command -v csf &>/dev/null; then
        echo -e "${YELLOW}[CSF]${NC} Applying..."
        case "$action" in
            whitelist) csf -a "$ip" "t4s whitelist" &>/dev/null ;;
            allow) csf -a "$ip" "t4s whitelist" &>/dev/null ;;
            blacklist) csf -d "$ip" "t4s blacklist" &>/dev/null ;;
            block) csf -d "$ip" "t4s blacklist" &>/dev/null ;;
            delete)    csf -ar "$ip" &>/dev/null; csf -dr "$ip" &>/dev/null ;;
        esac
        echo -e "${GREEN}[CSF] Done${NC}"
    else
        echo -e "${RED}[CSF] Not installed${NC}"
    fi

    # --- Imunify360 ---
    if command -v imunify360-agent &>/dev/null; then
        echo -e "${YELLOW}[Imunify360]${NC} Applying..."
        case "$action" in
            whitelist) imunify360-agent whitelist ip add "$ip" &>/dev/null ;;
            allow) imunify360-agent whitelist ip add "$ip" &>/dev/null ;;
            blacklist) imunify360-agent blacklist ip add "$ip" &>/dev/null ;;
            block) imunify360-agent blacklist ip add "$ip" &>/dev/null ;;
            delete)
                imunify360-agent whitelist ip delete "$ip" &>/dev/null
                imunify360-agent blacklist ip delete "$ip" &>/dev/null
                ;;
        esac
        echo -e "${GREEN}[Imunify360] Done${NC}"
    else
        echo -e "${RED}[Imunify360] Not installed${NC}"
    fi

    # --- iptables ---
    if command -v iptables &>/dev/null; then
        echo -e "${YELLOW}[iptables]${NC} Applying..."
        case "$action" in
            whitelist) iptables -I INPUT -s "$ip" -j ACCEPT &>/dev/null ;;
            allow) iptables -I INPUT -s "$ip" -j ACCEPT &>/dev/null ;;
            blacklist) iptables -I INPUT -s "$ip" -j DROP &>/dev/null ;;
            block) iptables -I INPUT -s "$ip" -j DROP &>/dev/null ;;
            delete)
                iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
                iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
                ;;
        esac
        echo -e "${GREEN}[iptables] Done${NC}"
    else
        echo -e "${RED}[iptables] Not installed${NC}"
    fi

    # --- cPHulk ---
    if [[ -x /usr/local/cpanel/scripts/cphulkdwhitelist ]]; then
        echo -e "${YELLOW}[cPHulk]${NC} Applying..."
        case "$action" in
            whitelist) /usr/local/cpanel/scripts/cphulkdwhitelist "$ip" &>/dev/null ;;
            allow) /usr/local/cpanel/scripts/cphulkdwhitelist "$ip" &>/dev/null ;;
            blacklist) /usr/local/cpanel/scripts/cphulkdblacklist "$ip" &>/dev/null ;;
            block) /usr/local/cpanel/scripts/cphulkdblacklist "$ip" &>/dev/null ;;
            delete)    /usr/local/cpanel/scripts/cphulkdwhitelist "$ip" &>/dev/null ;;
        esac
        echo -e "${GREEN}[cPHulk] Done${NC}"
    else
        echo -e "${RED}[cPHulk] Not installed${NC}"
    fi

    echo -e "${GREEN}✅ $action complete for $ip${NC}"
}


# Flush manually added rules
flush_rules() {
    /scripts/configure_firewall_for_cpanel
    /usr/local/cpanel/cpsrvd
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -F
    iptables -t mangle -F
    /usr/sbin/iptables -F
    /usr/sbin/iptables -X
}

# --- Main ---
case "$1" in
    "tools")
        bash <(curl -fsSL $SCRIPT_URI/tools.sh) || error_exit "Failed to execute Tools"
        ;;
    "rc")
        bash <(curl -fsSL $SCRIPT_URI/rc-system/rc.sh) || error_exit "Failed to execute RC System"
        ;;
    "rc-renew")
        bash <(curl -fsSL $SCRIPT_URI/rc-system/rc-renew.sh) || error_exit "Failed to execute RC System"
        ;;
    "syslic")
        bash <(curl -fsSL $SCRIPT_URI/rc-system/syslic.sh) || error_exit "Failed to execute Syslic"
        ;;
    "syslic-renew")
        bash <(curl -fsSL $SCRIPT_URI/rc-system/syslic-renew.sh) || error_exit "Failed to execute Syslic"
        ;;
    "tweak")
        bash <(curl -fsSL $SCRIPT_URI/tweaks.sh) || error_exit "Failed to execute Tweak Settings"
        ;;
    "update")
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/init) || error_exit "Failed to update the script"
        ;;
    "check-for-update")
        echo -e "${YELLOW}Checking for updates...${NC}"

        LOCAL_SCRIPT="/usr/local/bin/t4s"
        REMOTE_HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"

        # Get local version
        if [[ -f "$LOCAL_SCRIPT" ]]; then
            LOCAL_VERSION=$(grep 'LOCAL_SCRIPT_VERSION=' "$LOCAL_SCRIPT" | cut -d'"' -f2)
        else
            echo -e "${RED}Local t4s script not found at $LOCAL_SCRIPT${NC}"
            exit 1
        fi

        # Fetch remote version
        REMOTE_VERSION=$(curl -fsSL "$REMOTE_HEADER_URL" | grep 'LOCAL_SCRIPT_VERSION=' | cut -d'"' -f2) \
            || { echo -e "${RED}Failed to fetch remote version.${NC}"; exit 1; }

        # Compare versions
        if [[ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]]; then
            echo -e "${GREEN}Update available!${NC} Local: $LOCAL_VERSION → Remote: $REMOTE_VERSION"
            echo -e "${YELLOW}Updating t4s automatically...${NC}"
            bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/init) || error_exit "Failed to update the script"
            echo -e "${GREEN}t4s updated successfully to version $REMOTE_VERSION!${NC}"
        else
            echo -e "${GREEN}t4s is up to date (version $LOCAL_VERSION).${NC}"
        fi
        ;;
    "install-csf")
        bash <(curl -fsSL $SCRIPT_URI/csf.sh) || error_exit "Installation of CSF failed"
        ;;
    "ssl")
        echo -e "${GREEN}SSL certificates reconfiguration Srtarting...${NC}"
        /usr/local/cpanel/scripts/install_lets_encrypt_autossl_provider
        /usr/local/cpanel/bin/checkallsslcerts
        echo -e "${GREEN}SSL certificates reconfiguration completed.${NC}"
        ;;
    "resolve")
        echo -e "${YELLOW}Resolving $2...${NC}"
        echo "nameserver 8.8.8.8" | tee /etc/resolv.conf &>/dev/null
        echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf &>/dev/null &
        echo -e "${YELLOW}Resolving Done$2...${NC}"
        ;;
    "whitelist"|"allow"|"blacklist"|"block"|"delete")
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
