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
iptables-restore < /root/frontend/iptables-f.bak
iptables-save
service iptables save

#Установка и запуск сервиса nginx
yum -y install epel-release
yum -y install nginx
systemctl enable --now nginx
mv /root/frontend/apache-balance.conf /etc/nginx/conf.d/
rm -r /etc/nginx/nginx.conf
mv /root/frontend/nginx.conf /etc/nginx/
systemctl reload nginx.service

#Установка и запуск filebeat
yum -y install /root/frontend/*.rpm
rm -r /root/frontend/*.rpm
rsync -P /root/frontend/filebeat.yml /etc/filebeat/
systemctl enable --now filebeat

#Установка и запуск node-exporter
useradd --no-create-home --shell /bin/false node_exporter
rsync -P /root/frontend/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter
cp -v /root/frontend/node_exporter-1.4.0.linux-amd64/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now node_exporter.service

echo "Done!"









