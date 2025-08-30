#!/bin/bash

HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"
SCRIPT_URI="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Error handler

# Function to center text
center() {
    local text="$1"
    local padding=$(( (WIDTH - ${#text}) / 2 ))
    printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

# Function to display menu
show_menu() {
    clear
    source <(curl -sL $HEADER_URL)

    echo -e "${GREEN}1)${NC} Server Basic Config (Before Installation) ${RED}[Required]${NC}"
    echo -e "${GREEN}2)${NC} RC License Script"
    echo -e "${GREEN}3)${NC} Syslic License Script"
    echo -e "${GREEN}4)${NC} Official Plugin Installation"
    echo -e "${GREEN}5)${NC} Official Plugin Uninstallation"
    echo -e "${GREEN}6)${NC} Tools"
    echo -e "${GREEN}0)${NC} Exit"
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""
}

# Loop until valid choice
while true; do
    show_menu
    read -p "$(echo -e ${CYAN}Enter your choice [0-7]: ${NC})" choice

    case $choice in
        1)
            echo -e "${YELLOW}You selected: Server Basic Config${NC}"
            ;;
        2)
            echo -e "${YELLOW}You selected: RC License Script${NC}"
            bash <(curl -fsSL $SCRIPT_URI/rc-system/rc.sh)
            ;;
        3)
            echo -e "${YELLOW}You selected: Syslic License Script${NC}"
            bash <(curl -fsSL $SCRIPT_URI/rc-system/syslic.sh)
            ;;
        4)
            echo -e "${YELLOW}You selected: Official Plugin Installation${NC}"
            echo -e "${YELLOW}Feature coming soon...${NC}"
            exit 0
            ;;
        5)
            echo -e "${YELLOW}You selected: Official Plugin Uninstallation${NC}"
            echo -e "${YELLOW}Feature coming soon...${NC}"
            exit 0
            ;;
        6)
            echo -e "${YELLOW}Returning to Tools...${NC}"
            sleep 1
            bash <(curl -fsSL $SCRIPT_URI/tools.sh)
            ;;
        0)
            echo -e "${GREEN}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice! Please enter a number between 0 and 7.${NC}"
            sleep 2
            ;;
    esac
done
