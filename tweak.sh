#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "===================================================================="
echo -e "${YELLOW} Enabling Tweak Settings... ${NC}"

# Configure PHP settings
whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube &>/dev/null
whmapi1 set_tweaksetting key=php_upload_max_filesize value=550 &>/dev/null
whmapi1 set_tweaksetting key=php_post_max_size value=550 &>/dev/null

# Email limits
whmapi1 set_tweaksetting key=maxemailsperhour value=30 &>/dev/null
whmapi1 set_tweaksetting key=emailsperdaynotify value=100 &>/dev/null

# Public HTML subdirectories and unregistered domains
whmapi1 set_tweaksetting key=publichtmlsubsonly value=0 &>/dev/null
whmapi1 set_tweaksetting key=allowunregistereddomains value=1 &>/dev/null

# Disable password resets
whmapi1 set_tweaksetting key=resetpass value=0 &>/dev/null
whmapi1 set_tweaksetting key=resetpass_sub value=0 &>/dev/null

# Security settings
whmapi1 set_tweaksetting key=allowremotedomains value=1 &>/dev/null
whmapi1 set_tweaksetting key=referrerblanksafety value=1 &>/dev/null
whmapi1 set_tweaksetting key=referrersafety value=1 &>/dev/null
whmapi1 set_tweaksetting key=cgihidepass value=1 &>/dev/null
whmapi1 set_tweaksetting key=email_outbound_spam_detect_enable value=0 &>/dev/null

# TimezoneDB
yum install ea-php74-php-timezonedb ea-php80-php-timezonedb ea-php81-php-timezonedb ea-php82-php-timezonedb -y &>/dev/null
systemctl restart httpd &>/dev/null
for version in 74 80 81 82; do
  /opt/cpanel/ea-php$version/root/usr/bin/php -m | grep -q timezonedb
done

# MySQL settings
grep -q '^sql_mode=' /etc/my.cnf && sed -i 's/^sql_mode=.*/sql_mode=""'/ /etc/my.cnf || sed -i '/^\[mysqld\]/a sql_mode=""' /etc/my.cnf
/scripts/restartsrv_mysql &>/dev/null

# EasyApache 4 profile
mkdir -p /etc/cpanel/ea4/profiles/custom &>/dev/null
curl -s -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json &>/dev/null

echo -e "${GREEN}Tweak settings successfully applied!${NC}"
echo "===================================================================="
