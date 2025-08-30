#!/usr/bin/env bash

echo ">>> Setting Timezone & Locale to $2 & en_US.UTF-8"

sudo timedatectl set-timezone $2

# Disable the use of hardware based optimizations to avoid `Hash sum` error message
sudo mkdir /etc/gcrypt
sudo echo all >> /etc/gcrypt/hwf.deny

sudo locale-gen --purge en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
sudo dpkg-reconfigure --frontend=noninteractive locales

echo ">>> Installing Base Packages"

sudo apt-get -q=2 update --fix-missing
#sudo apt-get upgrade -y

# -qq implies -y --force-yes
#sudo -E apt-get -q=2 install -qq ack-grep bash-completion build-essential curl software-properties-common tree unzip whois zip
sudo -E apt-get -q=2 install -qq ack-grep bash-completion curl software-properties-common tree unzip whois zip

# Sometimes there are errors while installing packages...
#[[ $? -ne 0 ]] && { sudo -E apt-get -y --fix-broken install; }

echo ">>> Upgrading Git"

# Ubuntu 22.04 ships with Git 2.25.1 in upstream
# so let's add a repository from Git Maintainers
# for the latest stable version.
sudo add-apt-repository -y ppa:git-core/ppa

sudo -E apt-get install -qq git

# Disable case sensitivity
shopt -s nocasematch

if [[ ! -z $1 && ! $1 =~ false && $1 =~ ^[0-9]*$ ]]; then

    echo ">>> Setting up Swap ($1 MB)"

    # Create the Swap file
    fallocate -l $1M /swapfile

    # Set the correct Swap permissions
    chmod 600 /swapfile

    # Setup Swap space
    mkswap /swapfile

    # Enable Swap space
    swapon /swapfile

    # Make the Swap file permanent
    echo "/swapfile   none    swap    sw    0   0" | tee -a /etc/fstab

    # Add some swap settings:
    # vm.swappiness=10: Means that there wont be a Swap file until memory hits 90% useage
    # vm.vfs_cache_pressure=50: read http://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf && sysctl -p

fi

# Enable case sensitivity
shopt -u nocasematch
