#!/usr/bin/env bash

echo ">>> Installing MongoDB"

ENABLE_REMOTE=$1
MONGO_VERSION=$2
PHP_VERSION=$3

function create_mongod_conf {
cat <<- _CONF_
net:
   bindIp: 0.0.0.0
_CONF_
}

sudo apt-get install gnupg -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc | sudo gpg --dearmor -o /etc/apt/keyrings/mongodb-${MONGO_VERSION}.gpg
sudo touch /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/mongodb-server-${MONGO_VERSION}.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/${MONGO_VERSION} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list

sudo apt-get -y --fix-broken update;
#sudo apt-get update

# NOTE Ubuntu 22.04 is shipped with libssl3
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

sudo apt-get install -qq mongodb-org

# Make MongoDB connectable from outside world without SSH tunnel
if [ $ENABLE_REMOTE == "true" ]; then
    # enable remote access
    # setting the mongodb `bind ip` to allow connections from everywhere
    #sed -i "s/bind_ip = .*/bind_ip = 0.0.0.0/" /etc/mongod.conf
    if [ ! -f "/etc/mongod.conf" ]; then
        create_mongod_conf > /etc/mongod.conf
    fi

    sudo systemctl restart mongod.service
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

    # install php extension
if [ $PHP_IS_INSTALLED -eq 0 ]; then
    sudo apt-get -y install php${PHP_VERSION}-mongodb

    sudo systemctl restart php${PHP_VERSION}-fpm
fi
