#!/bin/bash
cd /usr/src
rm -f cse.tgz &>/dev/null
wget -q https://download.configserver.com/cse.tgz
tar -xzf cse.tgz &>/dev/null
cd cse
./install.sh &>/dev/null

cd /usr/src
    rm -f csf.tgz &>/dev/null
    wget -q https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz &>/dev/null
    cd csf
    ./install.sh &>/dev/null

    # Enable production mode
    sed -i 's/^TESTING = .*/TESTING = "0"/' /etc/csf/csf.conf

    # Fix RESTRICT_SYSLOG warning
    sed -i 's/^RESTRICT_SYSLOG = .*/RESTRICT_SYSLOG = "3"/' /etc/csf/csf.conf

    # Restart CSF to apply changes
    csf -r &>/dev/null