#!/usr/bin/env bash

PHP_VERSION=$1

echo ">>> Installing Mailcatcher"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

# Installing dependency
# -qq implies -y --force-yes
sudo -E apt-get install -qq libsqlite3-dev ruby-dev build-essential

# Setup a Gem installation directory
#echo -e '\n# Install Ruby Gems to ~/gems' >> ~/.bashrc
#echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
#echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
#source ~/.bashrc

# Install
sudo gem install --no-document mailcatcher

# Make it start on boot
sudo tee /lib/systemd/system/mailcatcher.service <<EOL
[Unit]
Description=Mailcatcher Service
After=network.target
Documentation=http://mailcatcher.me/

[Service]
Type=simple
ExecStart=/usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
SyslogIdentifier=mailcatcher # Use the name of service instead of 'env' in logs
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable Mailcatcher
sudo systemctl enable mailcatcher.service

# Start Mailcatcher
sudo systemctl start mailcatcher.service

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
    # Make php use it to send mail
    echo "sendmail_path = /usr/bin/env $(which catchmail)" | sudo tee /etc/php/${PHP_VERSION}/mods-available/mailcatcher.ini
    sudo phpenmod mailcatcher
    sudo systemctl restart php${PHP_VERSION}-fpm.service
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
    sudo systemctl restart apache2.service
fi
