#!/bin/bash
cd /usr/src
rm -fv cse.tgz
wget https://download.configserver.com/cse.tgz
tar -xzf cse.tgz
cd cse
./install.sh

cd /usr/src
    rm -fv csf.tgz
    wget https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz
    cd csf
    ./install.sh

    # Enable production mode
    sed -i 's/^TESTING = .*/TESTING = "0"/' /etc/csf/csf.conf

    # Fix RESTRICT_SYSLOG warning
    sed -i 's/^RESTRICT_SYSLOG = .*/RESTRICT_SYSLOG = "3"/' /etc/csf/csf.conf

    # Restart CSF to apply changes
    csf -r