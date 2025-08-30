#!/usr/bin/env bash

echo ">>> Installing MariaDB"

[[ -z $1 ]] && { echo "!!! MariaDB root password not set. Check the Vagrant file."; exit 1; }

# Update
#sudo -E apt-get update

# Install MariaDB
# -qq implies -y --force-yes
sudo -E apt-get install -qq mariadb-server

MYSQL=`which mysql`

# https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/

Q1="SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$1');"
Q2="CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';"
Q3="GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost' WITH GRANT OPTION;"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"
sudo $MYSQL -uroot -e "$SQL"

# Make Maria connectable from outside world without SSH tunnel
if [ $2 == "true" ]; then
    # enable remote access
    # setting the mysql bind-address to allow connections from everywhere
    sudo sed -i "s/bind-address.*/bind-address            = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

    # adding grant privileges to mysql root user from everywhere
    # thx to http://stackoverflow.com/questions/7528967/how-to-grant-mysql-privileges-in-a-bash-script for this
    Q1="GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"

    sudo $MYSQL -uroot -p$1 -e "$SQL"
fi

sudo systemctl restart mariadb.service
