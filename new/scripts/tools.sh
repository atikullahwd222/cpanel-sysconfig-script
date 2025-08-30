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

    echo ""
    echo -e "${GREEN}PAGE${NC}:${YELLOW} Tools${NC}"
    echo -e "${GREEN}Version${NC}:${YELLOW} $TOOLS_VERSION ${NC}"
    echo ""


    # Menu options
    echo -e "${GREEN}1)${NC} Tweak Settings"
    echo -e "${GREEN}2)${NC} PHP ini Config"
    echo -e "${GREEN}3)${NC} Full Server Config"
    echo -e "${GREEN}4)${NC} Allow IP"
    echo -e "${GREEN}5)${NC} Block IP"
    echo -e "${GREEN}6)${NC} Auto Config"
    echo -e "${GREEN}7)${NC} Flush Firewall"
    echo -e "${GREEN}0)${NC} Back to Main Menu"
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
            bash <(curl -fsSL $SCRIPT_URI/tweaks.sh) || error_exit "Failed to execute Twekas Settings"
            ;;
        2)
            echo -e "${YELLOW}Running PHP ini Config...${NC}"
            bash <(curl -fsSL $SCRIPT_URI/ini.sh) || error_exit "Failed to execute PHP ini Settings"
            ;;
        3)
            echo -e "${YELLOW}Running Tweaks Settings first...${NC}"
            bash <(curl -fsSL $SCRIPT_URI/tweaks.sh) || error_exit "Failed to execute Tweaks Settings"

            echo -e "${YELLOW}Go to EasyApache4, find BH-Profile, click Provision and wait until the process is done.${NC}"
            read -p "Press Enter once you have completed the provisioning..." dummy

            echo -e "${YELLOW}Running PHP ini Config now...${NC}"
            bash <(curl -fsSL $SCRIPT_URI/ini.sh) || error_exit "Failed to execute PHP ini Settings"
            ;;
        4)
            read -p "Enter IP or hostname to allow: " target_ip
            bash -c "$(curl -fsSL $SCRIPT_URI/whitelist.sh)" -- "$target_ip" || error_exit "Failed to execute Allow IP"
            ;;
        5)
            echo -e "${YELLOW}You selected: Official Plugin Uninstallation${NC}"
            ;;
        6)
            echo -e "${YELLOW}You selected: Auto Config${NC}"
            ;;
        7)
            bash <(curl -fsSL $SCRIPT_URI/tools.sh) || error_exit "Failed to execute Tools"
            ;;
        0)
            echo -e "${GREEN}Going back to main menu...${NC}"
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
