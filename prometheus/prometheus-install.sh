#!/bin/bash

#Установка доп. софта
yum install -y nano
yum install -y wget
yum install -y zsh

cat /root/prometheus/grafana_* > /root/prometheus/grafana-9.2.5-1.x86_64.rpm

#Настройка firewall
setenforce 0
sed -i "s/=enforcing/=permissive/" /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
yum -y install iptables-services.x86_64
systemctl enable --now iptables.service
iptables -F
iptables-restore < /root/prometheus/iptables-p.bak
iptables-save
service iptables save

#Установка и запуск prometheus
tar -xzvf /root/prometheus/prometheus-2.37.2.linux-amd64/prometheus.tar.gz -C /root/prometheus/prometheus-2.37.2.linux-amd64
rm -r /root/prometheus/prometheus-2.37.2.linux-amd64/prometheus.tar.gz
tar -xzvf /root/prometheus/prometheus-2.37.2.linux-amd64/promtool.tar.gz -C /root/prometheus/prometheus-2.37.2.linux-amd64
rm -r /root/prometheus/prometheus-2.37.2.linux-amd64/promtool.tar.gz
useradd --no-create-home --shell /usr/sbin/nologin prometheus
mkdir -v {/etc,/var/lib}/prometheus
chown -v prometheus: {/etc,/var/lib}/prometheus
rsync -P /root/prometheus/prometheus-2.37.2.linux-amd64/prometheus /root/prometheus/prometheus-2.37.2.linux-amd64/promtool /usr/local/bin
chown -v prometheus: /usr/local/bin/prometheus
chown -v prometheus: /usr/local/bin/promtool
cp -v /root/prometheus/prometheus-2.37.2.linux-amd64/prometheus.service /etc/systemd/system
mv /root/prometheus/prometheus-2.37.2.linux-amd64/console_libraries /etc/prometheus/
mv /root/prometheus/prometheus-2.37.2.linux-amd64/consoles /etc/prometheus/
cp -v /root/prometheus/prometheus-2.37.2.linux-amd64/prometheus.yml /etc/prometheus/
chown -v prometheus: /etc/prometheus/
systemctl daemon-reload
systemctl enable --now prometheus.service

#Установка и запуск grafana
yum -y install /root/prometheus/*rpm
rm -r /root/prometheus/*rpm
systemctl enable grafana-server.service 
systemctl start grafana-server.service
systemctl restart grafana-server.service

rm /root/prometheus/grafana_*

echo "Done!"








