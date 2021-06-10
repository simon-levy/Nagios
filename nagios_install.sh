#!/bin/bash
############################################
#
# Ngios install for docker container
#
# This script will run my install for
# nagios
#
# Test script only -- This will be tested
#                     on ubuntu 18.04 and
#                     20.04
#
# Author: Simon Levy
#
# Note: using nagios-4.4.6 which the latest
#       version at the time of writing this
#       script
#
############################################

clear

## check to be root
whoami=`whoami`
                if [ $whoami == "root" ]
                then
                        echo "You are root"
                else
                        echo "You need root access to continue"
                        exit
                fi

## Update system to latest packages
apt-update
apt install -y build-essential apache2 php openssl perl make php-gd libgd-dev libapache2-mod-php libperl-dev libssl-dev daemon wget apache2-utils unzip

## Adding usser and groups
useradd nagios && groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd www-data

## Download nagios -- version nagios-4.4.6
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar -zxvf /tmp/nagios-4.4.6.tar.gz
##cd /tmp/nagios-4.4.6/

## Compile nagios
make all
make install 
make install-init
make install-config
make install-commandmode

## compile nagios contacts
## NOTE: Need to run sed -i and change the file 

## Install nagios web interface
make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
a2enmod cgi
systemctl restart apache2

## Installing nagios plugin
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -zxvf /tmp/nagios-plugins-2.3.3.tar.gz
/tmp/nagios-plugins-2.3.3/configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

## Starting nagios
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
systemctl enable nagios
systemctl start nagios
