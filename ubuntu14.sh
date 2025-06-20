#! /bin/bash
echo "install apache2";
sudo apt-get install -y apache2

echo "install php5"
sudo apt-get install -y php5

echo "install mysql"
sudo apt-get install -y mysql-server

echo "php mods"
sudo apt-get install -y php5-mysql
sudo apt-get install -y php5-curl
sudo apt-get install -y php5-apcu
sudo apt-get install -y php5-imagick
sudo apt-get install -y php5-mcrypt

sudo php5enmod mcrypt

echo "apache mods"
sudo a2enmod rewrite

echo "restart apache"
sudo service apache2 restart


