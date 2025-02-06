# Define script version
SCRIPT_VERSION="1.0.0"
SCRIPT_URL="https://yourserver.com/whm_install_menu.sh"
LOCAL_SCRIPT_PATH="/usr/local/bin/whm_install_menu.sh"

# Function to check for updates
check_for_update() {
    echo -e "${GREEN}Checking for updates...${NC}"
    REMOTE_VERSION=$(curl -sL $SCRIPT_URL | grep "SCRIPT_VERSION=" | head -1 | cut -d '"' -f2)

    if [[ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]]; then
        echo -e "${YELLOW}Update available! Updating script...${NC}"
        curl -fsSL $SCRIPT_URL -o $LOCAL_SCRIPT_PATH
        chmod +x $LOCAL_SCRIPT_PATH
        echo -e "${GREEN}Script updated to version $REMOTE_VERSION! Restarting...${NC}"
        exec bash "$LOCAL_SCRIPT_PATH"
    else
        echo -e "${GREEN}No updates available.${NC}"
    fi
}

# Run the update check before execution
check_for_update
