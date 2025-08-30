#!/bin/bash
# Apply WHM Tweak Settings, MySQL changes, and EasyApache 4 profile
# Run as root

# Define colors
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)

echo "===================================================================="
echo -e "${YELLOW} Starting WHM Tweak Settings Configuration... ${NC}"
echo "===================================================================="

# ----------------------------
# PHP Loader & Limits
# ----------------------------
echo -e "${BLUE}Configuring PHP settings...${NC}"
whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube &>/dev/null
whmapi1 set_tweaksetting key=php_upload_max_filesize value=550 &>/dev/null
whmapi1 set_tweaksetting key=php_post_max_size value=550 &>/dev/null
echo -e "${GREEN}✔ PHP settings applied.${NC}"

# ----------------------------
# Email Limits
# ----------------------------
echo -e "${BLUE}Configuring Email limits...${NC}"
whmapi1 set_tweaksetting key=maxemailsperhour value=30 &>/dev/null
whmapi1 set_tweaksetting key=emailsperdaynotify value=100 &>/dev/null
echo -e "${GREEN}✔ Email limits applied.${NC}"

# ----------------------------
# Domains & Public HTML settings
# ----------------------------
echo -e "${BLUE}Configuring domain/public_html settings...${NC}"
whmapi1 set_tweaksetting key=publichtmlsubsonly value=0 &>/dev/null
whmapi1 set_tweaksetting key=allowunregistereddomains value=1 &>/dev/null
echo -e "${GREEN}✔ Domain/public_html settings applied.${NC}"

# ----------------------------
# Password Reset settings
# ----------------------------
echo -e "${BLUE}Disabling password reset options...${NC}"
whmapi1 set_tweaksetting key=resetpass value=0 &>/dev/null
whmapi1 set_tweaksetting key=resetpass_sub value=0 &>/dev/null
echo -e "${GREEN}✔ Password reset disabled.${NC}"

# ----------------------------
# Security Settings
# ----------------------------
echo -e "${BLUE}Applying security settings...${NC}"
whmapi1 set_tweaksetting key=allowremotedomains value=1 &>/dev/null
whmapi1 set_tweaksetting key=referrerblanksafety value=1 &>/dev/null
whmapi1 set_tweaksetting key=referrersafety value=1 &>/dev/null
whmapi1 set_tweaksetting key=cgihidepass value=1 &>/dev/null
whmapi1 set_tweaksetting key=email_outbound_spam_detect_enable value=0 &>/dev/null
echo -e "${GREEN}✔ Security settings applied.${NC}"

# ----------------------------
# MySQL Settings
# ----------------------------
echo -e "${BLUE}Configuring MySQL settings...${NC}"
grep -q '^sql_mode=' /etc/my.cnf && \
    sed -i 's/^sql_mode=.*/sql_mode=""/' /etc/my.cnf || \
    sed -i '/^\[mysqld\]/a sql_mode=""' /etc/my.cnf
/scripts/restartsrv_mysql &>/dev/null
echo -e "${GREEN}✔ MySQL settings applied.${NC}"

# ----------------------------
# EasyApache 4 Profile
# ----------------------------
echo -e "${BLUE}Applying EasyApache 4 custom profile...${NC}"
mkdir -p /etc/cpanel/ea4/profiles/custom &>/dev/null
curl -s -o /etc/cpanel/ea4/profiles/custom/EasyApache4-BH-Custome.json \
    https://raw.githubusercontent.com/atikullahwd222/cpanel-sysconfig-script/refs/heads/main/EasyApache4-BH-Custome.json &>/dev/null
echo -e "${GREEN}✔ EasyApache 4 custom profile applied.${NC}"

echo "===================================================================="
echo -e "${GREEN}All tweak settings successfully applied!${NC}"
echo "===================================================================="
