#!/bin/bash

#Настройка репликации
#echo "Enter mysql root password:"  
#read -s pass
#USER='root'
PASS='Testpass1$' 
rsync -P /root/mysql-s/my.cnf /etc
systemctl restart mysqld

logpos=$1

#Необходимо заменить на актуальные MASTER_LOG_FILE и MASTER_LOG_POS mysql-master
echo "CHANGE MASTER TO MASTER_HOST='192.168.0.111', MASTER_USER='repl', MASTER_PASSWORD='Replpass1$', MASTER_LOG_FILE='binlog.000001', MASTER_LOG_POS=$logpos, GET_MASTER_PUBLIC_KEY = 1;" | mysql -uroot -p$PASS
echo "START SLAVE;" | mysql -uroot -p$PASS
#echo "SHOW SLAVE STATUS\G" | mysql -uroot -p'Testpass1$'

#Добавление задачи в cron для автоматического резервного копирования данных wordpress
mkdir /root/mysql-s/backup
rsync -P /root/mysql-s/crontab /etc
systemctl restart crond.service

echo "Done!"
