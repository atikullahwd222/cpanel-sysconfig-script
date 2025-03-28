#!/bin/bash
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

source <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/version.sh)

Theme4Sell_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh"

# Interactive menu
echo -e "    ____  __  __   _____            __               "
echo -e "   / __ )/ / / /  / ___/__  _______/ /____  ____ ___ "
echo -e "  / __  / /_/ /   \__ \/ / / / ___/ __/ _ \/ __ \`__ \\ "
echo -e " / /_/ / __  /   ___/ / /_/ (__  ) /_/  __/ / / / / /"
echo -e "/_____/_/_/_/_  /____/\__, /____/\__/\___/_/ /_/ /_/ "
echo -e "                     /____/                     v$TOOLS_VERSION"
echo -e "                                                     "
echo -e ""
echo ""
echo "1 - Fresh Installer"
echo "2 - WHM Plugins Installer"
echo "3 - WHM Plugins Uninstaller"
echo "0 - Go back"

read -p "Enter your choice (0-3): " choice

case "$choice" in
    "1")
        echo -e "${GREEN}You selected Fresh Installer.${NC}"
        echo ""
        echo ""
        echo "1 - Budget Licensing System"
        echo "2 - RC Licensing System"
        echo "0 - Go back"
        
        read -p "Enter your choice (0-2): " sub_choice
        
        case "$sub_choice" in
            "1")
            echo -e "${GREEN}You selected Budget Licensing System.${NC}"
            echo ""
            echo ""
            echo -e "${YELLOW}Redirecting...${NC}"
            echo ""
            sleep 1
            clear
            bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/theme4sell.sh) || error_exit "Failed to execute Budget Licensing System"
            ;;
            
            "2")
            echo -e "${GREEN}You selected RC Licensing System.${NC}"
            echo ""
            echo ""
            echo -e "${YELLOW}Redirecting...${NC}"
            echo ""
            sleep 1
            clear
            bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/rc-licensing.sh) || error_exit "Failed to execute RC Licensing System"
            ;;
            
            "0")
            echo -e "${GREEN}Going back to main menu.${NC}"
            echo ""
            echo ""
            echo -e "${YELLOW}Redirecting...${NC}"
            echo ""
            sleep 1
            clear
            bash <(curl -fsSL $Theme4Sell_URL) || error_exit "Failed to execute Theme4Sell"
            ;;
            
            *)
            echo -e "${RED}Unknown command: $sub_choice${NC}"
            exit 1
            ;;
        esac
        ;;
    
    "2")
        echo -e "${GREEN}You selected WHM Plugins Installer.${NC}"
        echo ""
        echo ""
        echo -e "${YELLOW}Redirecting...${NC}"
        echo ""
        sleep 1
        clear
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/whm-plugins.sh) || error_exit "Failed to execute WHM Plugins Installer"
        ;;

    "3")
        echo -e "${GREEN}You selected WHM Plugins Uninstaller.${NC}"
        echo ""
        echo ""
        echo -e "${YELLOW}Redirecting...${NC}"
        echo ""
        sleep 1
        clear
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/whm-plugins-uninstall.sh) || error_exit "Failed to execute WHM Plugins Uninstaller"
        ;;

    "0")
        echo -e "${GREEN}Going back to main menu.${NC}"
        echo ""
        echo ""
        echo -e "${YELLOW}Redirecting...${NC}"
        echo ""
        sleep 1
        clear
        bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh) || error_exit "Failed to execute Main Menu"
        ;;

    *)
        echo -e "${RED}Unknown command: $choice${NC}"
        exit 1
        ;;
esac