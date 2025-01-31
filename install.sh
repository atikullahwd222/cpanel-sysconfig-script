#!/bin/bash

# Function to prompt user for input
prompt_input() {
    read -p "$1: " input
    echo "$input"
}

# Get user input
server_ip=$(prompt_input "Enter the server IP")
hostname=$(prompt_input "Enter the hostname")
hostname_prefix=$(prompt_input "Enter the hostname prefix")

# Update /etc/hosts
echo "$server_ip $hostname $hostname_prefix" | sudo tee -a /etc/hosts

# Setting up DNS resolvers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Installing nano text editor
yum install nano -y

# Updating system and installing AlmaLinux release
yum update -y
yum install almalinux-release -y

# Disabling firewalld
iptables-save > ~/firewall.rules
systemctl stop firewalld.service
systemctl disable firewalld.service

clear
# Confirm installation choices
echo "===================================================================================================="
install_cpanel=$(prompt_input "Do you want to install cPanel? (y/n)")
install_litespeed=$(prompt_input "Do you want to install and activate LiteSpeed License? (y/n)")
install_softaculous=$(prompt_input "Do you want to install Softaculous? (y/n)")
install_jetbackup=$(prompt_input "Do you want to install JetBackup? (y/n)")
install_whmreseller=$(prompt_input "Do you want to install WHMReseller? (y/n)")
install_sitepad=$(prompt_input "Do you want to install SitePad? (y/n)")
install_im360=$(prompt_input "Do you want to install Imunify360? (y/n)")
install_cloudlinux=$(prompt_input "Do you want to install CloudLinux? (y/n)")
echo "===================================================================================================="

echo "You have 30 seconds to decide whether to start the installation or not..."
sleep 30


echo "Do you want to proceed with the installation? (y/n)"
read proceed

# Installing cPanel
if [[ "$install_cpanel" == "y" ]]; then
    cd /home
    curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
    sysconfig cpanel update
    sysconfig cpanel enable
    sysconfig cpanel fleetssl
    sysconfig cpanel noupdate
else
    echo "Skipping cPanel installation. Exiting..."
    exit 1
fi

# Running MagicByte repo script
curl -sL https://repo.magicbyte.pw/init.sh | sudo bash -

# Installing and enabling LiteSpeedX
if [[ "$install_litespeed" == "y" ]]; then
    sysconfig litespeedx install
    sysconfig litespeedx enable
fi

# Installing and enabling Softaculous
if [[ "$install_softaculous" == "y" ]]; then
    sysconfig softaculous install
    echo "Please visit https://www.softaculous.com/trial/ to get a trial license."
fi

# Installing and enabling JetBackup
if [[ "$install_jetbackup" == "y" ]]; then
    sysconfig jetbackup install
    sysconfig jetbackup enable
fi

# Installing and enabling WHMReseller
if [[ "$install_whmreseller" == "y" ]]; then
    sysconfig whmreseller install
    sysconfig whmreseller enable
fi

# Installing and enabling SitePad
if [[ "$install_sitepad" == "y" ]]; then
    sysconfig sitepad install
    sysconfig sitepad enable
fi

# Installing and enabling Imunify360
if [[ "$install_im360" == "y" ]]; then
    sysconfig im360 install
    sysconfig im360 enable
fi

# Running StarLicense basic needs script
bash <( curl https://api.starlicense.net/basic-needs.sh )

# Installing and enabling CloudLinux
if [[ "$install_cloudlinux" == "y" ]]; then
    sysconfig cloudlinux install
    sysconfig cloudlinux enable
fi

# Final confirmation
echo "Installation process completed."
