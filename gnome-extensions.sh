#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

function update_packages{
    echo -e "$Cyan \n » UPDATING SYSTEM $Color_Off"
    sudo apt-get update -y && apt-get upgrade
}

function aptinstall{
    for item in $@; do
        echo -e "$Green \n » INSTALLING $item $Red"
        sudo apt-get install "$@" -y -f -qq
    done
}

function aptremove{
    for item in $@; do
        echo -e "$Purple \n » REMOVING $item $Red"
        sudo apt-get remove "$@" -y -f -qq
    done
}

#***********************************************************************************
#	CONFIGURE THEME
#***********************************************************************************
function install_themes(){
	
	aptinstall GNOME-SHELL-EXTENSIONS gnome-shell-extensions
	aptinstall libqt5svg5 qml-module-qtquick-controls
	aptinstall CHROME-SHELL-INTEGRATION chrome-gnome-shell
	aptinstall gnome-shell-extension-weather
	aptinstall gnome-shell-extension-ubuntu-dock
	aptinstall gnome-shell-extension-bluetooth-quick-connect
	aptinstall gnome-tweak-tool

	#changing login screen
	sudo cp $DIR/login-theme/bg-login.png /usr/share/backgrounds/
	sudo cp /usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.bk
	sudo cp $DIR/login-theme/ubuntu.css /usr/share/gnome-shell/theme/

	#changing grub theme
	sudo source $DIR/grub-theme/install.sh sudo -b -l -w

}
