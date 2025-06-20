#!/bin/bash
echo "Updating package lists";
sudo apt-get update -y

echo "Installing essential tools";
sudo apt-get install -y zip curl unzip

echo "Installing Apache2";
sudo apt-get install -y apache2

echo "Installing PHP (v8.2 on Ubuntu 24.04 by default)";
sudo apt-get install -y php php-cli

echo "Installing MySQL Server";
sudo apt-get install -y mysql-server

echo "Installing PHP extensions required for Laravel 11";
# PHP 8.2 ships several extensions (such as ctype, fileinfo, JSON, openssl,
# PDO and tokenizer) as part of the core package. Installing them via
# `apt-get` would fail because there are no separate packages. Only modules
# that are distributed as packages need to be installed explicitly.
sudo apt-get install -y \
    php-bcmath \
    php-mbstring \
    php-xml \
    php-mysql \
    php-curl \
    php-zip \
    php-apcu \
    php-imagick

echo "Enabling Apache2 and PHP modules";
sudo apt-get install -y libapache2-mod-php
sudo a2enmod rewrite

echo "Installing Composer (Dependency Manager for PHP)";
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "Restarting Apache2";
sudo systemctl restart apache2

echo "Server setup completed successfully with Laravel 11 requirements!";
