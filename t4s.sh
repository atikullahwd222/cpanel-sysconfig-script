#!/bin/bash
# bash <(curl -s https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/install.sh)
# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Log file location
LOG_FILE="/var/log/t4s_install.log"

# Function to log messages with timestamp
log_message() {
    local MESSAGE=$1
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${MESSAGE}" | tee -a "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    local ERROR_MSG=$1
    log_message "${RED}ERROR: ${ERROR_MSG}${NC}"
    exit 1
}

# Start of the script
log_message "${GREEN}Starting t4s process...${NC}"

# Ensure curl is installed
if ! command -v curl &> /dev/null; then
    error_exit "curl is not installed. Please install curl and try again."
fi

# Ensure we are running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    log_message "${YELLOW}Warning: You are not running as root. You may need to enter sudo passwords during installation.${NC}"
fi

# Create directory for t4s if it does not exist
log_message "${GREEN}Creating Binaries...${NC}"
mkdir -p /usr/local/bin

# Function to check for script updates
check_for_update() {
    log_message "${GREEN}Checking for t4s script updates...${NC}"

    # Fetch the latest script version from GitHub
    local REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/t4s.sh | head -n 1)
    local CURRENT_VERSION=$(head -n 1 /usr/local/bin/t4s)

    if [[ "$REMOTE_VERSION" != "$CURRENT_VERSION" ]]; then
        log_message "${YELLOW}Update available for t4s script.${NC}"
        log_message "${GREEN}Downloading the latest version...${NC}"

        curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/t4s.sh -o /usr/local/bin/t4s || error_exit "Failed to download the latest version of t4s."

        log_message "${GREEN}t4s script updated successfully!${NC}"
    else
        log_message "${GREEN}No updates available for t4s script.${NC}"
    fi
}

# Check and update t4s if necessary
check_for_update

# Set execute permissions on the downloaded t4s script (if it was updated)
log_message "${GREEN}Setting execute permissions${NC}"
chmod +x /usr/local/bin/t4s || error_exit "Failed to set execute permissions on t4s."

# Run install.sh directly from GitHub (no download)
log_message "${GREEN}Running install.sh directly...${NC}"
bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/install.sh) || error_exit "Failed to execute install.sh."

# Success message
log_message "${GREEN}Installation completed successfully!${NC}"

# End of the script
exit 0
