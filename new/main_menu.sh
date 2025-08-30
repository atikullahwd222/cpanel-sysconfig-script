#!/bin/bash

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Version
VERSION="1.0"

# Width of the menu
WIDTH=50

# Function to center text
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

# Print Header
echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
echo -e "${BLUE}$(center "🌟 Theme4Sell Configuration Menu 🌟")${NC}"
echo -e "${BLUE}$(center "Version $VERSION")${NC}"
echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
echo ""

# Warning Section
echo -e "${RED}$(center "⚠⚠⚠ WARNING ⚠⚠⚠")${NC}"
echo -e "${YELLOW}$(center "Please complete the server basic configuration")${NC}"
echo -e "${YELLOW}$(center "before proceeding with installation!")${NC}"
echo -e "${CYAN}$(center "Select option 1 for server preparation.")${NC}"
echo -e "${RED}$(printf '*%.0s' $(seq 1 $WIDTH))${NC}"
echo ""


# Menu Options
echo -e "${GREEN}1)${NC} Server Basic Config (Before Installation) ${RED}[Required]${NC}"
echo -e "${GREEN}2)${NC} RC License Script"
echo -e "${GREEN}3)${NC} Syslic License Script"
echo -e "${GREEN}4)${NC} Official Installation Scripts"
echo -e "${GREEN}5)${NC} Auto Config"
echo -e "${GREEN}6)${NC} Whitelist an IP"
echo -e "${GREEN}7)${NC} Blacklist an IP"
echo -e "${GREEN}8)${NC} DNS Flush"
echo -e "${GREEN}9)${NC} Hard DNS Flush"
echo -e "${GREEN}10)${NC} Reset All DNS Zones"
echo -e "${GREEN}11)${NC} Allow Our IPs"
echo -e "${GREEN}0)${NC} Exit"

echo ""
echo -e "${BLUE}==================================================${NC}"
