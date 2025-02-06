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

# Always fetch and run the latest script
SCRIPT_URL="https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/menu.sh"

echo -e "${GREEN}Fetching the latest script version...${NC}"
exec bash <(curl -fsSL "$SCRIPT_URL")