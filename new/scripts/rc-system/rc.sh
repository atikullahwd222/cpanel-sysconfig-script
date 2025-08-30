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


    # Menu options
    echo -e "${GREEN}1)${NC} Server Basic Config (Before Installation) ${RED}[Required]${NC}"
    echo -e "${GREEN}2)${NC} All in One Script"
    echo -e "${GREEN}0)${NC} Go Back to Main Menu"
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

