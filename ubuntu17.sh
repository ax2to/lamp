#! /bin/bash
echo "install tools";
sudo apt-get install zip -y
sudo apt-get install curl -y

echo "install apache2";
sudo apt-get install apache2 -y

echo "install php7"
sudo apt-get install php -y

echo "install mysql"
sudo apt-get install mysql-server -y

echo "php mods"
sudo apt-get install php-mbstring -y
sudo apt-get install php-json -y
sudo apt-get install php-xml -y
sudo apt-get install php-mysql -y
sudo apt-get install php-curl -y
sudo apt-get install php-apcu -y
sudo apt-get install php-imagick -y
sudo apt-get install php-mcrypt -y
sudo apt-get install php-zip -y

sudo phpenmod mcrypt

echo "apache mods"
sudo apt-get install libapache2-mod-php -y
sudo a2enmod rewrite

echo "restar apache"
sudo service apache2 restart
