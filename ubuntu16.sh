#! /bin/bash
echo "install apache2";
sudo apt-get install apache2

echo "install php7"
sudo apt-get install php

echo "install mysql"
sudo apt-get install mysql-server

echo "php mods"
sudo apt-get install php-mbstring
sudo apt-get install php-json
sudo apt-get install php-xml
sudo apt-get install php-mysql
sudo apt-get install php-curl
sudo apt-get install php-apcu
sudo apt-get install php-imagick
sudo apt-get install php-mcrypt

sudo phpenmod mcrypt

echo "apache mods"
sudo apt-get install libapache2-mod-php
sudo a2enmod rewrite

echo "restart apache"
sudo service apache2 restart


