#!/bin/bash

# This file contains basic tool functions used by menu.sh
# It expects to be sourced by menu.sh, which defines color vars and log()

# Whitelist an IP (placeholder implementation)
whitelist_ip() {
  echo -e "${YELLOW}Whitelisting an IP...${NC}"
  read -p "Enter the IP address to whitelist: " ip_address
  if [[ ! "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Invalid IP address format.${NC}"
    log "Invalid IP address for whitelist: $ip_address"
    return 1
  fi
  echo -e "${YELLOW}Adding $ip_address to whitelist...${NC}"
  # TODO: Replace with actual firewall/csf allow command
  echo -e "${GREEN}IP $ip_address whitelisted (placeholder).${NC}"
  log "Whitelisted IP $ip_address (placeholder)"
}

# Blacklist an IP (placeholder implementation)
blacklist_ip() {
  echo -e "${YELLOW}Blacklisting an IP...${NC}"
  read -p "Enter the IP address to blacklist: " ip_address
  if [[ ! "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Invalid IP address format.${NC}"
    log "Invalid IP address for blacklist: $ip_address"
    return 1
  fi
  echo -e "${YELLOW}Adding $ip_address to blacklist...${NC}"
  # TODO: Replace with actual firewall/csf deny command
  echo -e "${GREEN}IP $ip_address blacklisted (placeholder).${NC}"
  log "Blacklisted IP $ip_address (placeholder)"
}

# DNS Flush (current lightweight/iptables reset sequence from option 8)
dns_flush_basic() {
  echo -e "${YELLOW}Flushing DNS cache...${NC}"
  systemctl restart named &>/dev/null &
  local pid=$!
  # spinner is defined in menu.sh; only call if available
  if declare -f spinner >/dev/null 2>&1; then spinner $pid; else wait $pid; fi

  /scripts/configure_firewall_for_cpanel
  /usr/local/cpanel/cpsrvd
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -t nat -F
  iptables -t mangle -F
  /usr/sbin/iptables -F
  /usr/sbin/iptables -X

  log "DNS cache flushed (basic)"
}

# Allow Our IPs (existing behavior in repository was performing hard DNS flush under option 9)
# Keeping a dedicated function to make future updates easier.
allow_our_ips() {
  echo -e "${YELLOW}Performing hard DNS flush...${NC}"
  # Bind/named cache
  systemctl restart named &>/dev/null
  rm -rf /var/cache/named/* &>/dev/null &
  local pid=$!
  if declare -f spinner >/dev/null 2>&1; then spinner $pid; else wait $pid; fi

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
}

# Unsuspend all users (placeholder)
unsuspend_all_users() {
for user in $(ls /var/cpanel/suspended/); do
    /scripts/unsuspendacct $user
done
}

# Reset all DNS zones (placeholder)
reset_all_dns_zones() {
    BACKUP_DIR="/root/dnsbackup_$(date +%F_%H%M)"
    mkdir -p "$BACKUP_DIR"

    echo "📦 Backing up all DNS zones to $BACKUP_DIR..."
    cp /var/named/*.db "$BACKUP_DIR/" || { echo "❌ Backup failed!"; exit 1; }

    # Get all unique domains from /etc/trueuserdomains
    domains=$(awk -F: '{gsub(/ /,"",$1); if ($1) print $1}' /etc/trueuserdomains | sort -u)

    for domain in $domains; do
        if [ -n "$domain" ]; then
            echo "🔄 Resetting DNS zone for $domain"

            # Reset zone using WHM API
            if /usr/local/cpanel/bin/whmapi1 resetzone domain="$domain" >/dev/null 2>&1; then
                echo "✅ Zone reset successfully"
            else
                echo "❌ Error: Failed to reset zone for $domain"
            fi

            echo "✅ $domain done"
        fi
    done

    # Reload named once at the end
    if /scripts/restartsrv_named >/dev/null 2>&1; then
        echo "🔄 named service restarted successfully"
    else
        echo "⚠️ Warning: Failed to restart named service"
    fi

    echo "🎉 All DNS zones reset. Backup saved in $BACKUP_DIR"
}
