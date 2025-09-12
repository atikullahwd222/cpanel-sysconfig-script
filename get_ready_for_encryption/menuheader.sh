#!/bin/bash
# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Version
SCRIPT_URI="https://script.theme4sell.com/scripts"
LOCAL_SCRIPT_VERSION="2.1.1"
SCRIPT_VERSION="2.1.1"
TOOLS_VERSION="2.1.1"

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
    echo -e "${BLUE}$(center "Version $SCRIPT_VERSION")${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""

    # Warning
    echo -e "${RED}$(center "⚠ ⚠ ⚠ WARNING ⚠ ⚠ ⚠")${NC}"
    echo -e "${YELLOW}$(center "Please complete the server basic configuration")${NC}"
    echo -e "${YELLOW}$(center "before proceeding with installation!")${NC}"
    echo -e "${CYAN}$(center "Select option 1 for server preparation.")${NC}"
    echo -e "${RED}$(printf '*%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""