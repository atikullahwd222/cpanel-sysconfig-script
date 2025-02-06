#!/bin/bash
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}ERROR: curl is not installed. Please install curl and try again.${NC}"
    exit 1
fi

# Ensure we are running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Warning: You are not running as root. You may need to enter sudo passwords during installation.${NC}"
fi

# Create directory for t4s if it does not exist
echo -e "${GREEN}Creating Binaries...${NC}"
mkdir -p /usr/local/bin

clear

# Interactive menu
echo "Thanks for Choosing us. Go with ..."
echo "1 - Theme4Sell v2"
echo "2 - GB Lic"
echo "3 - I just want to install WHM and Tweaks"
echo "4 - Exit"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}You selected Theme4Sell.${NC}"
        echo -e "${GREEN}Helow world.${NC}"
        ;;
    2)
        echo -e "${GREEN}You selected GB Lic.${NC}"
        ;;
    3)
        echo -e "${GREEN}You selected WHM and Tweaks installation.${NC}"
        ;;
    4)
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option! Please select 1-4.${NC}"
        exit 1
        ;;
esac