#! /bin/bash
echo "install apache2";
sudo apt-get install -y apache2

echo "install php7"
sudo apt-get install -y php

echo "install mysql"
sudo apt-get install -y mysql-server

echo "php mods"
sudo apt-get install -y php-mbstring
sudo apt-get install -y php-json
sudo apt-get install -y php-xml
sudo apt-get install -y php-mysql
sudo apt-get install -y php-curl
sudo apt-get install -y php-apcu
sudo apt-get install -y php-imagick
sudo apt-get install -y php-mcrypt

sudo phpenmod mcrypt

echo "apache mods"
sudo apt-get install -y libapache2-mod-php
sudo a2enmod rewrite

echo "restart apache"
sudo service apache2 restart


