#!/bin/bush

#Установка доп. софта
yum install -y nano
yum install -y wget
yum install -y zsh

cat /root/elk/logstash_a* > /root/elk/logstash_7.17.3_x86_64-224190-3a605f.rpm
cat /root/elk/elastic_a* > /root/elk/elasticsearch_7.17.3_x86_64-224190-9bcb26.rpm
cat /root/elk/kibana_a* > /root/elk/kibana_7.17.3_x86_64-224190-b13e53.rpm

#Настройка firewall
setenforce 0
sed -i "s/=enforcing/=permissive/" /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
yum -y install iptables-services.x86_64
systemctl enable --now iptables.service
iptables -F
iptables-restore < /root/elk/iptables-e.bak
iptables-save
service iptables save

#Установка java и сервисов elk
yum -y install java-openjdk-devel java-openjdk
yum -y install /root/elk/*.rpm
rm -r /root/elk/*.rpm
#Установка лимитов памяти для виртуальной машины java
mv /root/elk/jvm.options /etc/elasticsearch/jvm.options.d

#Запуск сервиса elasticsearch
systemctl enable --now elasticsearch.service
curl http://127.0.0.1:9200
#Создание тестового индекса
curl -X PUT "http://127.0.0.1:9200/mytest_index"

#Запуск сервиса kibana
rsync -P /root/elk/kibana.yml /etc/kibana
chown -R :kibana /etc/kibana/kibana.yml
systemctl enable --now kibana

#Запуск сервиса logstash
rsync -P /root/elk/logstash.yml /etc/logstash
rsync -P /root/elk/*.conf /etc/logstash/conf.d
systemctl restart logstash.service

#Установка и запуск node-exporter
useradd --no-create-home --shell /bin/false node_exporter
rsync -P /root/elk/node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter
cp -v /root/elk/node_exporter-1.4.0.linux-amd64/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now node_exporter.service

rm /root/elk/logstash_a*
rm /root/elk/elastic_a*
rm /root/elk/kibana_a*

echo "Done!"

