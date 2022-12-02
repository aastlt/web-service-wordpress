#!/bin/bash

#Установка доп. софта
yum install -y nano
yum install -y wget
yum install -y zsh

#Настройка firewall
setenforce 0
sed -i "s/=enforcing/=permissive/" /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
yum -y install iptables-services.x86_64
systemctl enable --now iptables.service
iptables -F
iptables-restore < /root/mysql-m/iptables-m-m.bak
iptables-save
service iptables save

#Установка и запуск сервиса MySQL
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-7.noarch.rpm
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
yum -y --enablerepo=mysql80-community install mysql-community-server
chkconfig mysqld on
service mysqld start

#Установка и запуск filebeat
yum -y install /root/mysql-m/*.rpm
rm -r /root/mysql-m/*.rpm
rsync -P /root/mysql-m/filebeat.yml /etc/filebeat/
systemctl enable --now filebeat

#Установка и запуск node-exporter
useradd --no-create-home --shell /bin/false node_exporter
rsync -P /root/mysql-m/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter
cp -v /root/mysql-m/node_exporter-1.4.0.linux-amd64/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now node_exporter.service

#Смена временного пароля и настройка безопасности mysql
grep "A temporary password" /var/log/mysqld.log
mysql_secure_installation

#Настройка репликации (создадим пользователя для репликации и установим пароль Replpass1$)
#USER='root'
PASS='Testpass1$'
#echo "Enter mysql root password:"  
#read -s pass 
echo "CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'Replpass1$';" | mysql -uroot -p$PASS
echo "GRANT REPLICATION SLAVE ON *.* TO repl@'%';" | mysql -uroot -p$PASS
echo "SHOW MASTER STATUS;" | mysql -uroot -p$PASS

echo "Done!"
 
