#!/bin/bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

 # Check if running as root  
 if [ "$(id -u)" != "0" ]; then  
   echo -e "$Red This script must be run as root"
   exit 1  
 fi  

function update_packages(){
    echo -e "$Cyan \n » UPDATING SYSTEM $Color_Off"
    sudo apt-get update -y && apt-get upgrade
}

function aptinstall(){
    for item in $@; do
        echo -e "$Green \n » INSTALLING $item $Red"
        sudo apt-get install "$@" -y -f -qq
    done
}

function aptremove(){
    for item in $@; do
        echo -e "$Purple \n » REMOVING $item $Red"
        sudo apt-get remove "$@" -y -f -qq
    done
}

# Update Package Index
update_packages

#cleaning older instalations
aptremove apache2 mysql-server php libapache2-mod-php php-cli
aptremove libapache2-mod-php php php-common php-curl php-dev php-gd php-pear php-imagick php-ps php-pspell php-xsl php-mbstring

# Install Apache2, MySQL, PHP
aptinstall apache2 mysql-server php libapache2-mod-php php-cli

# Install PHP Modules
aptinstall libapache2-mod-php php php-common php-curl php-dev php-gd php-pear php-imagick php-ps php-pspell php-xsl php-mbstring

sudo apt autoremove

# Install Adminer
echo -e "$Green \n »0 INSTALLING Adminer $Color_Off"
cd /var/www/html/
git clone https://github.com/pematon/adminer-custom.git adminer

# Allow to run Apache on boot up
echo -e "$Yellow \n » Allowing to run Apache on boot up $Color_Off"
sudo systemctl enable apache2

# Restart Apache Web Server
echo -e "$Yellow \n » Restarting Apache $Color_Off"
sudo systemctl start apache2

# Adjust Firewall
echo -e "$Yellow \n » Adjust Apache Firewall $Color_Off"
sudo ufw allow in "Apache Full"

# Allow Read/Write for Owner
echo -e "$Yellow \n » Allowing Read/Write for Owner $Color_Off"
sudo chmod -R 0755 /var/www/html/
sudo chown -R www-data:www-data /var/www  

# Create info.php for testing php processing
echo -e "$Yellow \n » Creating info.php $Color_Off"
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php


echo -e "$Yellow \n » ENABLING PHP AND APACHE MODULES $Color_Off"
sudo phpenmod mbstring
sudo a2enmod rewrite

echo -e "$Yellow \n » Changing index.php > index.html priority $Color_Off"
sudo sed -i 's/index.php //g' /etc/apache2/mods-enabled/dir.conf
sudo sed -i 's/index.html/index.php index.html/g' /etc/apache2/mods-enabled/dir.conf

# Open localhost in the default browser
echo -e "$Cyan \n » INSTALATION FINISHED: $Color_Off"
echo -e "$Cyan » Open http://localhost in the default browser $Color_Off"
#runuser -l  $user -c 'xdg-open "http://localhost/info.php"'

# Restart Apache Web Server
echo -e "$Yellow \n » Restarting Apache $Color_Off"
sudo systemctl restart apache2
sudo systemctl status apache2
