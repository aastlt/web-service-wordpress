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
iptables-restore < /root/backend/iptables-b.bak
iptables-save
service iptables save

#Установка сервиса apache
yum install -y httpd
systemctl enable --now httpd.service

#Установка php и php-модулей
rpm -ivh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install epel-release yum-utils
yum-config-manager --enable remi-php74
yum -y install php php-cli php-mbstring php-gd php-mysqlnd php-xmlrpc php-xml php-zip php-curl
systemctl restart httpd.service

#Установка wordpress
mv /root/backend/wordpress.conf /etc/httpd/conf.d
cp -r /root/backend/wordpress /var/www/wordpress
cp -r /root/backend/wordpress /var/www/wordpress1
cp -r /root/backend/wordpress /var/www/wordpress2
chown -R apache:apache /var/www/wordpress*
systemctl reload httpd.service

#Установка и запуск filebeat
yum -y install /root/backend/*.rpm
rm -r /root/backend/*.rpm
rsync -P /root/backend/filebeat.yml /etc/filebeat/
systemctl enable --now filebeat

#Установка и запуск node-exporter
useradd --no-create-home --shell /bin/false node_exporter
rsync -P /root/backend/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter
cp -v /root/backend/node_exporter-1.4.0.linux-amd64/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now node_exporter.service

echo "Done!"













