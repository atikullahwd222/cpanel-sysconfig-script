#!/bin/bash
# blacklist.sh
# Usage: blacklist.sh <IP_or_hostname>

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

IP="$1"
if [[ -z "$IP" ]]; then
    echo -e "${RED}Usage: $0 <IP_or_hostname>${NC}"
    exit 1
fi

resolve_ip() {
    echo "$(dig +short "$1" | head -n1 || echo "$1")"
}

IP=$(resolve_ip "$IP")
echo -e "${YELLOW}Processing blacklist for $IP...${NC}"

# t4s block
if command -v t4s >/dev/null 2>&1; then
    echo -e "${YELLOW}[t4s] Blocking IP...${NC}"
    t4s block "$IP"
fi

# --- CSF ---
if command -v csf >/dev/null 2>&1; then
    echo -e "${YELLOW}[CSF] Adding to blacklist...${NC}"
    csf -d "$IP" "t4s blacklist"
    echo -e "${GREEN}[CSF] Done.${NC}"
fi

# --- Imunify360 ---
if command -v imunify360-agent >/dev/null 2>&1; then
    echo -e "${YELLOW}[Imunify360] Adding to blacklist...${NC}"
    imunify360-agent blacklist ip add "$IP"
    echo -e "${GREEN}[Imunify360] Done.${NC}"
fi

# --- iptables ---
if command -v iptables >/dev/null 2>&1; then
    echo -e "${YELLOW}[iptables] Blocking IP...${NC}"
    iptables -I INPUT -s "$IP" -j DROP
    # Save iptables
    if command -v netfilter-persistent >/dev/null 2>&1; then
        netfilter-persistent save >/dev/null 2>&1
    elif command -v service >/dev/null 2>&1; then
        service iptables save 2>/dev/null || iptables-save > /etc/iptables/rules.v4
    fi
    echo -e "${GREEN}[iptables] Done.${NC}"
fi

# --- cPHulk ---
if command -v whmapi1 >/dev/null 2>&1; then
    echo -e "${YELLOW}[cPHulk] Adding to blacklist...${NC}"
    whmapi1 cphulkd_blacklist_add ip="$IP" >/dev/null
    echo -e "${GREEN}[cPHulk] Done.${NC}"
fi

echo -e "${GREEN}✅ IP $IP blacklisted successfully!${NC}"
