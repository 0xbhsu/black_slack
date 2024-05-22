#!/bin/bash
###############################################
#                  CONSTANTS                  #
###############################################
BURPSUITE_VERSION="2024.3.1.4"
BLOODHOUND_VERSION="4.3.1"
SUBFINDER_VERSION="2.6.6"
SECLISTS_VERSION="2024.1"
GOBUSTER_VERSION="3.6.0"
FUFF_VERSION="2.1.0"
REGULAR_USER="user" # change this



###############################################
#                  FUNCTIONS                  #
###############################################
usage() {
    echo "Usage: ./black_slack.sh [tools|wordlists|all]"
}

sboinstall_package() {
    local package_name=$1
    sbopkg -k -q -B -i $package_name
}

install_tools() {
    echo "Updating sbopkg before we install the tools"
    sbopkg -r
    echo "Installing metasploit-framework"
    # metasploit - postgresql required
    sboinstall_package postgresql
    sboinstall_package metasploit; chown -R postgres:postgres /opt/metasploit/postgresql
    echo "Installing sqlmap"
    pip3 install sqlmap
    echo "Installing netexec"
    # netexec - pipx required
    sqg -p python3-pipx -o pipxqueue
    sboinstall_package pipxqueue
    export PIPX_HOME="/opt/pipx"
    export PIPX_BIN_DIR="/usr/local/bin"
    pipx install git+https://github.com/Pennyw0rth/NetExec
    echo "Installing impacket"
    wget "https://github.com/fortra/impacket/releases/download/impacket_0_9_24/impacket-0.9.24.tar.gz" -O - | tar -xvz -C /tmp ; python3 /tmp/impacket-0.9.24/setup.py install; rm -rf /tmp/impacket-0.9.24
    echo "Installing wireshark"
    sboinstall_package wireshark
    groupadd wireshark
    usermod -a -G wireshark $REGULAR_USER
    chgrp wireshark /usr/bin/dumpcap
    chmod 750 /usr/bin/dumpcap
    setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
    echo "Installing crunch"
    # I don't use sudo
    git clone https://github.com/jim3ma/crunch /tmp/crunch; cd /tmp/crunch; sed 's/sudo//g' Makefile > newMakefile; mv newMakefile Makefile; make install; rm -rf /tmp/crunch; cd /tmp
    echo "Installing bloodhound"
    # neo4j - openjdk11 required
    sboinstall_package zulu-openjdk11
    wget "https://dist.neo4j.org/neo4j-community-4.4.33-unix.tar.gz" -O - | tar -xvz -C /tmp; mv /tmp/neo4j-community-4.4.33 /opt/neo4j; chown -R ${REGULAR_USER}:${REGULAR_USER} /opt/neo4j; ln -s /opt/neo4j/bin/neo4j /usr/bin/neo4j
    wget "https://github.com/BloodHoundAD/BloodHound/releases/download/v${BLOODHOUND_VERSION}/BloodHound-linux-x64.zip" -O /tmp/bloodhound.zip; cd /tmp; unzip bloodhound.zip; mv BloodHound-linux-x64 /opt/bloodhound; ln -s /opt/bloodhound/Bloodhound /usr/bin/bloodhound; rm -rf /tmp/bloodhound.zip; cd /tmp
    echo "Installing wafw00f"
    git clone https://github.com/EnableSecurity/wafw00f /tmp/wafw00f; python3 /tmp/wafw00f/setup.py install; rm -rf /tmp/wafw00f
    echo "Installing subfinder"
    wget "https://github.com/projectdiscovery/subfinder/releases/download/v${SUBFINDER_VERSION}/subfinder_${SUBFINDER_VERSION}_linux_amd64.zip" -O /tmp/subfinder.zip; cd /tmp/; unzip subfinder.zip; mv subfinder /usr/bin/subfinder; rm -rf /tmp/subfinder.zip; cd /tmp
    echo "Installing evil-winrm"
    gem install evil-winrm
    echo "Installing wpscan"
    gem install wpscan
    echo "Installing gobuster"
    wget "https://github.com/OJ/gobuster/releases/download/v${GOBUSTER_VERSION}/gobuster_Linux_x86_64.tar.gz" -O - | tar -xvz -C /tmp; mv /tmp/gobuster /usr/bin/gobuster
    echo "Installing ffuf"
    wget "https://github.com/ffuf/ffuf/releases/download/v${FUFF_VERSION}/ffuf_${FUFF_VERSION}_linux_amd64.tar.gz" -O - | tar -xvz -C /tmp; mv /tmp/ffuf /usr/bin/ffuf
    echo "Installing burpsuite-pro"
    wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=${BURPSUITE_VERSION}&type=Linux" -O /tmp/burp.sh; sh /tmp/burp.sh; rm /tmp/burp.sh; cd /tmp
    echo "Installing hashcat"
    sboinstall_package hashcat
    echo "Installing john"
    mkdir /tmp/john; cd /tmp/john; git clone "https://github.com/openwall/john" john_source; cd /tmp/john/john_source/src; ./configure && make -s clean && make -sj4; mv /tmp/john/john_source/run /opt/john; chown -R ${REGULAR_USER}:${REGULAR_USER} /opt/john; rm -rf /tmp/john;
}

install_wordlists() {
    echo "Installing wordlists"
    cd /tmp; wget "https://github.com/danielmiessler/SecLists/archive/refs/tags/${SECLISTS_VERSION}.tar.gz" -O - | tar -xvz; mv "SecLists-${SECLISTS_VERSION}" /usr/share/wordlists;
    wget "https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz" -O /tmp/rockyou.txt.gz; cd /tmp; gzip -d rockyou.txt.gz; mv rockyou.txt /usr/share/wordlists/; rm -rf /tmp/rockyou.txt.gz
    chown -R ${REGULAR_USER}:${REGULAR_USER} /usr/share/wordlists/
}



###############################################
#                  EXECUTION                  #
###############################################
if [ ! "$(id -u)" -eq 0 ]; then
    echo "You should run this as the root user!"
    exit 1
else
    if [ "$#" -ne 1 ]; then
        usage
        exit 1
    fi
fi

case "$1" in
    "tools")
        install_tools
        ;;
    "wordlists")
        install_wordlists
        ;;
    "all")
        install_tools
        install_wordlists
        ;;
    *)
        usage
        exit 1
        ;;
esac