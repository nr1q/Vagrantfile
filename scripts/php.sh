#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
PHP_VERSION=$2

echo ">>> Installing PHP $PHP_VERSION"

# Ubuntu 20.04 ships with PHP 7.4 in upstream
sudo add-apt-repository -y ppa:ondrej/php

#sudo -E apt-get clean
#sudo -E apt-get update

# Install PHP
# -qq implies -y --force-yes
if [[ $PHP_VERSION == '8.1' ]]; then
    sudo -E apt-get install -qq php-cli php-curl php-fpm php-gd php-imagick php-intl php-json php-mbstring php-mysql php-sqlite3 php-xml php-zip
else
    sudo -E apt-get install -qq php${PHP_VERSION}-cli php${PHP_VERSION}-curl php${PHP_VERSION}-fpm php${PHP_VERSION}-gd php${PHP_VERSION}-imagick php${PHP_VERSION}-intl php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-sqlite php${PHP_VERSION}-xml php${PHP_VERSION}-zip
fi

# Set PHP FPM to listen on TCP instead of Socket
sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Set run-as user for PHP-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
# NOTE next command may need to be based on php version
sudo sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# PHP Error Reporting Config
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini

# PHP Date Timezone
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php/${PHP_VERSION}/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php/${PHP_VERSION}/cli/php.ini

sudo systemctl start php${PHP_VERSION}-fpm
