#!/bin/bash
HEADER_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/new/menuheader.sh"
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

    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${GREEN}           cPanel & Software Installation Script RC System${NC}"
    echo -e "${BLUE}================================================================================${NC}"

    # Menu options
    printf "${BOLD}Select an installation option:${NC}\n"

    printf "${BLUE} 1)${NC} All-in-One Auto Installer ${YELLOW}(Beginner Friendly)${NC}\n"
    printf "${BLUE} 2)${NC} Install/Activate cPanel License\n"
    printf "${BLUE} 3)${NC} Install/Activate LiteSpeed Web Server License\n"
    printf "${BLUE} 4)${NC} Install/Activate LiteSpeed Load Balancer ${RED}(DDoS Protection)${NC} License\n"
    printf "${BLUE} 5)${NC} Install/Activate Softaculous License\n"
    printf "${BLUE} 6)${NC} Install/Activate JetBackup License\n"
    printf "${BLUE} 7)${NC} Install/Activate WHMReseller License\n"
    printf "${BLUE} 8)${NC} Install/Activate Imunify360 License\n"
    printf "${BLUE} 9)${NC} Install/Activate cPGuard License\n"
    printf "${BLUE}10)${NC} Install/Activate Da-Reseller License\n"
    printf "${BLUE}11)${NC} Install/Activate OSM License\n"
    printf "${BLUE}12)${NC} Install/Activate CXS License\n"
    printf "${BLUE}13)${NC} Install/Activate CloudLinux License\n"
    printf "${BLUE}14)${NC} Install/Activate SitePad License\n\n"

    printf "${RED} 0) Go Back${NC}\n"
    echo
    read -p "Enter your choice [0-14]: " choice
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
            echo -e "${YELLOW}Redirecting to the System Setup Script...${NC}"
            ;;
        2)
            echo -e "${YELLOW}Redirecting to All in one Script....${NC}"
            sleep 2
            bash <(curl -fsSL $SCRIPT_URI/rc-system/all-in-one.sh) || error_exit "Failed to execute All in One Script."
            ;;
        0)
            echo -e "${GREEN}Going back to Main Menu...${NC}"
            t4s
            ;;
        *)
            echo -e "${RED}Invalid choice! Please enter a number between 0 and 7.${NC}"
            sleep 2
            ;;
    esac

    # Pause before returning to menu
    echo ""
    read -p "Press Enter to return to menu..."
done

