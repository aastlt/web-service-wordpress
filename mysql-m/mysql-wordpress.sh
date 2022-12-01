#!/bin/bash

#Создание базы данных wordpress
#echo "Enter mysql root password:"  
#read -s pass
#USER='root'
PASS='Testpass1$' 
echo "CREATE DATABASE wpdb;" | mysql -uroot -p$PASS

#Создание пользователя для базы wordpress с паролем Passw0_rd и правами доступа
echo "CREATE USER 'wpuser'@'%' IDENTIFIED WITH mysql_native_password BY 'Passw0_rd';" | mysql -uroot -p$PASS
echo "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'%';" | mysql -uroot -p$PASS
echo "FLUSH PRIVILEGES;" | mysql -uroot -p$PASS

echo "Database for Wordpress configured!"


