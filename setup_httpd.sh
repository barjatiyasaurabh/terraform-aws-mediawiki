#!/bin/bash

echo "Mariadb private IP is $1" > mariadb-private-ip.txt
sudo dnf -y install httpd php php-mysqlnd php-gd php-xml mariadb php-mbstring php-json vim epel-release wget
sudo systemctl enable httpd

wget https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.2.tar.gz
tar -zxf mediawiki-1.34.2.tar.gz

sudo mv mediawiki-1.34.2 /var/www/html/mediawiki/
sudo chown -R root:root /var/www/html/

sudo setenforce 0
sudo sed -i 's/=enforcing/=disabled/g' /etc/sysconfig/selinux

sudo systemctl restart httpd

exit 0
