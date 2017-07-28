#!/bin/sh
sudo cat << EOF >> /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB-5.5.45
baseurl=http://yum.mariadb.org/5.5.45/centos6-amd64/
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

# Rename service to mariadb

sudo yum erase -y mariadb*;
sudo yum install -y MariaDB-client-5.5.45-1.el6.x86_64 MariaDB-common-5.5.45-1.el6.x86_64 MariaDB-compat-5.5.45-1.el6.x86_64 MariaDB-devel-5.5.45-1.el6.x86_64 MariaDB-server-5.5.45-1.el6.x86_64 MariaDB-shared-5.5.45-1.el6.x86_64;

if [ -e /etc/init.d/mysql ]; then
    sudo mv /etc/init.d/mysql /etc/init.d/mariadb;
    #sudo chkconfig --del mysql && sudo chkconfig --add mariadb && sudo chkconfig mariadb on;
    sudo systemctl stop mysql.service && sudo systemctl disable mysql.service &&  systemctl enable mariadb.service && systemctl daemon-reload;
fi;

sudo mkdir -p /var/log/mariadb && sudo chown -R mysql:mysql /var/log/mariadb;
grep "log_error" /etc/my.cnf.d/server.cnf || sed -i '/\[mysqld\]/a \log_error=\/var\/log\/mariadb\/mariadb.log' /etc/my.cnf.d/server.cnf

service mariadb start && sleep 5;
mysql -e "SELECT 1";

if [ "$?" -eq 0 ]; then
    ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 10);
    echo -e "\n\n$ROOT_PASSWORD\n$ROOT_PASSWORD\n\n\n\n\n " | mysql_secure_installation 2>/dev/null;
    echo "$ROOT_PASSWORD" > /home/vagrant/mariadb_pw.txt;
    echo "The MariaDB root password has been saved in /home/vagrant/mariadb_pw.txt. Please take note and delete the file.";
else
    echo "mysql_secure_installation has previously been run you can ignore the above warning.";
fi;