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
iptables-restore < /root/mysql-s/iptables-m-s.bak
iptables-save
service iptables save

#Установка и запуск сервиса MySQL
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-7.noarch.rpm
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
yum -y --enablerepo=mysql80-community install mysql-community-server
chkconfig mysqld on
service mysqld start

#Установка и запуск filebeat
yum -y install /root/mysql-s/*.rpm
rm -r /root/mysql-s/*.rpm
rsync -P /root/mysql-s/filebeat.yml /etc/filebeat/
systemctl enable --now filebeat

#Установка и запуск node-exporter
useradd --no-create-home --shell /bin/false node_exporter
rsync -P /root/mysql-s/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter
cp -v /root/mysql-s/node_exporter-1.4.0.linux-amd64/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now node_exporter.service

#Смена временного пароля
grep "A temporary password" /var/log/mysqld.log
mysql_secure_installation

echo "Done!"
