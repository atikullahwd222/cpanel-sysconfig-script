#!/bin/bash
# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Version (centralized)
BASE_URI="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new"
SCRIPT_URI="$BASE_URI/scripts"
# Read toolkit and component versions from central version.sh
VERS_CONTENT=$(curl -fsSL "$BASE_URI/version.sh" 2>/dev/null || true)
T4S_VERSION=$(printf "%s" "$VERS_CONTENT" | grep '^T4S_VERSION=' | cut -d '"' -f2)
T4S_MENU_VERSION=$(printf "%s" "$VERS_CONTENT" | grep '^T4S_MENU_VERSION=' | cut -d '"' -f2)
T4S_FIXER_VERSION=$(printf "%s" "$VERS_CONTENT" | grep '^T4S_FIXER_VERSION=' | cut -d '"' -f2)
SCRIPT_VERSION="${T4S_VERSION:-unknown}"

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Width of the menu
WIDTH=50

# Function to center text
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

# Header
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo -e "${BLUE}$(center "🌟 Theme4Sell Configuration Menu 🌟")${NC}"
    echo -e "${BLUE}$(center "Toolkit: ${T4S_VERSION:-unknown}")${NC}"
    echo -e "${BLUE}$(center "Menu: ${T4S_MENU_VERSION:-unknown}  |  Fixer: ${T4S_FIXER_VERSION:-unknown}")${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""

    # Warning
    echo -e "${RED}$(center "⚠ ⚠ ⚠ WARNING ⚠ ⚠ ⚠")${NC}"
    echo -e "${YELLOW}$(center "Please complete the server basic configuration")${NC}"
    echo -e "${YELLOW}$(center "before proceeding with installation!")${NC}"
    echo -e "${CYAN}$(center "Select option 1 for server preparation.")${NC}"
    echo -e "${RED}$(printf '*%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""