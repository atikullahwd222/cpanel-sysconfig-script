#!/bin/bash

# Script to apply PHP.ini modifications to all ea-php and alt-php versions in WHM/cPanel
# Run as root. This will backup each php.ini before modifying.
# Changes include:
# - zlib.output_compression = On
# - disable_functions = show_source, system, shell_exec, passthru, exec, mail
# - max_execution_time = 3000
# - max_input_time = 6000
# - max_input_vars = 1000 (uncomment if needed)
# - memory_limit = 256M
# - post_max_size = 256M
# - upload_max_filesize = 256M
# - allow_url_fopen = On

# Define colors
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Display warning and get confirmation
echo "${RED}WARNING: Do the tweak and EA4 Setting and then come to ini config${RESET}"
echo ""
echo "${YELLOW}Are you sure you want to proceed with the PHP.ini modifications? (y/n)${RESET}"
read -p "" confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "${RED}Operation cancelled.${RESET}"
    exit 0
fi

# Function to apply sed commands
apply_changes() {
    local ini_file="$1"
    if [ -f "$ini_file" ]; then
        echo "${BLUE}Processing: ${YELLOW}$ini_file${RESET}"
        cp "$ini_file" "$ini_file.bak"
        echo "${GREEN}Backup created: ${YELLOW}$ini_file.bak${RESET}"
        
        sed -i 's/^zlib.output_compression = .*/zlib.output_compression = On/' "$ini_file"
        sed -i 's/^disable_functions =.*/disable_functions = mail/' "$ini_file"
        sed -i 's/^disable_functions =.*/disable_functions = show_source, system, shell_exec, passthru, exec, mail/' "$ini_file"
        sed -i 's/^max_execution_time = .*/max_execution_time = 30000/' "$ini_file"
        sed -i 's/^max_input_time = .*/max_input_time = 60000/' "$ini_file"
        sed -i 's/^;*max_input_vars =.*/max_input_vars = 10000/' "$ini_file"
        sed -i 's/^memory_limit = .*/memory_limit = 2048M/' "$ini_file"
        sed -i 's/^post_max_size = .*/post_max_size = 2048M/' "$ini_file"
        sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2048M/' "$ini_file"
        sed -i 's/^allow_url_fopen = .*/allow_url_fopen = On/' "$ini_file"
        
        echo "${GREEN}✔ Changes applied successfully${RESET}"
        echo ""
    else
        echo "${YELLOW}${ini_file%/root/etc/php.ini}${ini_file%/etc/php.ini} not installed${RESET}"
    fi
}

echo "${BLUE}Starting PHP.ini modifications...${RESET}"
echo ""

# EA-PHP
echo "${BLUE}Processing ea-php versions:${RESET}"
for dir in /opt/cpanel/ea-php*/; do
    php_ini="${dir}root/etc/php.ini"
    if [ -d "$dir" ]; then
        apply_changes "$php_ini"
    fi
done

# ALT-PHP
echo "${BLUE}Processing alt-php versions:${RESET}"
for dir in /opt/alt/php*/; do
    php_ini="${dir}etc/php.ini"
    if [ -d "$dir" ]; then
        apply_changes "$php_ini"
    fi
done

echo "${GREEN}All modifications complete.${RESET}"
echo "${YELLOW}Note: You may need to restart PHP services (systemctl restart httpd ea-php*-php-fpm alt-php*-php-fpm) for changes to take effect.${RESET}"
