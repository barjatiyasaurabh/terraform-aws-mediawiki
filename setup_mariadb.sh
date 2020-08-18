#!/bin/bash

echo "Mariadb setup script ran" > mariadb-output.txt

sudo dnf -y install mariadb-server mariadb vim epel-release
sudo dnf -y install sshpass
sudo systemctl start mariadb

MYSQL_ROOT_PASSWORD=$(cat mysql-root-password)
mysqladmin -u root password $MYSQL_ROOT_PASSWORD
cat > db-setup-input.txt <<EOF
CREATE USER 'mediawiki'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE mediawiki;
GRANT ALL PRIVILEGES ON mediawiki.* TO 'mediawiki'@'%';
FLUSH PRIVILEGES;
exit
EOF
sshpass -f mysql-root-password mysql -u root -p < db-setup-input.txt


sudo systemctl enable mariadb



exit 0
