#!/usr/bin/env bash

echo ">>> Installing Apache Server"

[[ -z $1 ]] && { echo "!!! IP address not set. Check the Vagrant file."; exit 1; }

if [[ -z $2 ]]; then
    public_folder="/vagrant"
else
    public_folder="$2"
fi

if [[ -z $4 ]]; then
    resources_url="https://nrq.me/scripts/vagrant"
else
    resources_url="$4"
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?
PHP_VERSION=$5

# Add repo for latest FULL stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2
#sudo -E apt-get update

# Install Apache
# -qq implies -y --force-yes
sudo -E apt-get install -qq apache2

echo ">>> Configuring Apache"

# Add vagrant user to www-data group
sudo usermod -a -G www-data vagrant

# Apache Config
#sudo a2dismod mpm_prefork mpm_worker
sudo a2enmod rewrite
sudo a2enmod headers
#sudo a2enmod ssl
curl --silent -L $resources_url/helpers/vhost.sh > vhost
sudo chmod guo+x vhost
sudo mv vhost /usr/local/bin

# Create a virtualhost to start, with SSL certificate
# TODO implement SSL correctly
#sudo vhost -s $1.nip.io -d $public_folder -p /etc/ssl/nip.io -c nip.io -a $3
ls -la $public_folder
sudo vhost -s $3 -d $public_folder
sudo a2dissite 000-default

# If PHP is installed, proxy PHP requests to it
if [[ $PHP_IS_INSTALLED -eq 0 ]]; then

    # PHP Config for Apache
    sudo a2enmod proxy_fcgi
    sudo a2enconf php${PHP_VERSION}-fpm
    sudo systemctl restart php${PHP_VERSION}-fpm
fi

sudo systemctl restart apache2
