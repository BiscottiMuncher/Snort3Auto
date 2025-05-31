#!/bin/bash

#Auto Installter for Snort 3

# Install all needed packaged
preIn(){
        apt-get update -y && apt-get upgrade -y
        apt-get install git unzip ethtool build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev libfl-dev -y

        # Make snort source install directory

        mkdir ~/snort_src && cd ~/snort_src
}

## Clone Git repo for libdaq and Install
libdaqIn(){
        cd ~/snort_src
        git clone https://github.com/snort3/libdaq.git
        cd libdaq
        bash bootstrap
        bash configure
        make
        make install
}

## Install LIBPCRE
libpcre2In(){
        cd ~/snort_src
        wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.45/pcre2-10.45.zip
        unzip pcre2-10.45.zip
        cd ~/snort_src/pcre2-10.45/
        bash configure
        make
        make install

}

## Install Thread caching if arg is found
threadIn(){
        cd ~/snort_src
        wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
        tar xzf gperftools-2.9.1.tar.gz
        cd gperftools-2.9.1/
        bash configure
        make
        make install
}

## Download Snort then install
snortIn(){
        cd ~/
        wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
        unzip master.zip
        cd snort3-master
        bash configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
        cd ~/snort3-master/build
        make
        make install
        ldconfig
        clear
        echo "SNORT 3 INSTALLED THREADING ENABLED"
}

## Non-Threaded install
snortInNoT(){
        cd ~/
        wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
        unzip master.zip
        cd snort3-master
        bash configure_cmake.sh --prefix=/usr/local
        cd ~/snort3-master/build
        make
        make install
        ldconfig
        clear
        echo "SNORT 3 INSTALLED"
}


## Creates SystemD daemon to set adaptor in promisc mode on boot
snortPersist(){
        echo "Setting device as: $2" 
        echo "[Unit]
Description=Set NIC in promiscuous mode and Disable GRO, LRO 
After=network.target
[Service]
Type=oneshot
ExecStart=/usr/sbin/ip link set dev "$2" promisc on
ExecStart=/usr/sbin/ethtool -K "$2" gro off lro off
TimeoutStartSec=0
RemainAfterExit=yes
[Install]
WantedBy=default.target
EOL" > /etc/systemd/system/snort3-nic.service 

        ## Restart Daemon  
        systemctl daemon-reload 
        systemctl enable --now snort3-nic.service 
        systemctl status snort3-nic 
}

## Creates Directories for Snort Rules, Logs, and Blacklists
createDirs(){
        echo "Creating Needed Snort Directories"
        mkdir /usr/local/etc/rules
        touch /usr/local/etc/rules/local.rules
        mkdir /usr/local/etc/so_rules
        mkdir /usr/local/etc/lists
        mkdir /var/log/snort
}

## Main install loop

if [ "$1" == "-t" ]; then
        preIn
        libdaqIn
        libpcre2In
        threadIn
        snortIn
        snortPersist $2
        createDirs
        echo "Install Finished, Happy sniffing!"
elif [ "$1" == "-n" ]; then
        preIn
        libdaqIn
        libpcre2In
        snortInNoT
        snortPersist $2
        createDirs
        echo "Install Finished, Happy sniffing!"
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        echo ">Install Options:
        -t: installs with threating enabled (More performance, more memory usage)
        -n: installs without threading

        Example: Installing with threading and binding to eth0
          snortauto -t eth0
"
else
        echo "run snortauto -h or snortauto --help for options"
fi
