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

# Download and install the t4s script
log_message "${GREEN}Downloading t4s script${NC}"
curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/t4s.sh -o /usr/local/bin/t4s || error_exit "Failed to Exicute t4s. Contact to support"

# Set execute permissions on the downloaded t4s script
log_message "${GREEN}Setting execute permissions${NC}"
chmod +x /usr/local/bin/t4s || error_exit "Failed to set execute permissions on t4s."

# Check if the file was successfully installed
if [[ -x /usr/local/bin/t4s ]]; then
    log_message "${GREEN}t4s script successfully installed!${NC}"
else
    error_exit "t4s script installation failed."
fi

# Run install.sh directly from GitHub (no download)
log_message "${GREEN}Running install.sh directly...${NC}"
bash <(curl -fsSL https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/install.sh) || error_exit "Failed to execute install.sh."

# Success message
log_message "${GREEN}Installation completed successfully!${NC}"

# End of the script
exit 0
