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
    echo -e "${GREEN}6)${NC} Flush Firewall"
    echo -e "${GREEN}7)${NC} Reset All DNS Zones"
    echo -e "${GREEN}8)${NC} Suspend All Accounts"
    echo -e "${GREEN}9)${NC} Unsuspend All Accounts"
    echo -e "${GREEN}10)${NC} Disable Root mail sendings"
    echo -e "${YELLOW}0)${NC} Back to Main Menu"
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $WIDTH))${NC}"
    echo ""
}

# Loop until valid choice
while true; do
    show_menu
    read -p "$(echo -e ${CYAN}Enter your choice [0-9]: ${NC})" choice

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
            t4s allow "$target_ip"
            ;;
        5)
            read -p "Enter IP or hostname to Block: " target_ip
            t4s block "$target_ip"
            ;;
        6)
            echo -e "${YELLOW}Flushing DNS cache...${NC}"
            echo -e "${RED}⚠️ ⚠️ ⚠️${NC}"
            echo -e "${RED}Do not modify nameserver configuration files while this process runs.${NC}"
            read -p "${YELLOW}Press Enter wehn you are ready... ${NC}${RED}Ctrl+C to cancel${NC}" dummy
            /usr/local/cpanel/scripts/cleandns

            /scripts/configure_firewall_for_cpanel
            /usr/local/cpanel/cpsrvd
            iptables -P INPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -t nat -F
            iptables -t mangle -F
            /usr/sbin/iptables -F
            /usr/sbin/iptables -X
            ;;
        7)
            echo -e "${YELLOW}Resetting all DNS zones...${NC}"
            bash <(curl -fsSL $SCRIPT_URI/reset_all_dns_zone.sh) || error_exit "Failed to execute Tools"
            ;;
        8)
            echo -e "${YELLOW}Suspending all accounts...${NC}"
            for user in $(ls /var/cpanel/suspended/); do
                /scripts/unsuspendacct $user
            done
            ;;
        9)
            echo -e "${YELLOW}Unsuspending all accounts...${NC}"
            for user in $(ls /var/cpanel/suspended/); do
                /scripts/unsuspendacct $user
            done
            ;;
        10)
            echo -e "${YELLOW}Disabling root mail sendings...${NC}"
            read -p "Are you sure you want to disable all root mail sendings? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                whmapi1 set_tweaksetting key=skipdiskusage value=0
                whmapi1 set_tweaksetting key=skipdiskcheck value=0
                whmapi1 set_tweaksetting key=skipoomcheck value=1
                whmapi1 set_tweaksetting key=skipboxcheck value=0
                whmapi1 set_tweaksetting key=skipbwlimitcheck value=1
                whmapi1 set_tweaksetting key=notify_expiring_certificates value=0
            else
                echo -e "${RED}Operation cancelled.${NC}"
            fi
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
