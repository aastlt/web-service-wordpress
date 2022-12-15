#!/bin/bash

DB=wpdb;
USER='root'
PASS='Testpass1$'
DIR="/root/mysql-m/wpdb*"

#echo "Enter mysql root password:"
#read -s pass 

#echo "CREATE DATABASE wpdb;" | mysql -u$USER -p$PASS
#echo "CREATE USER 'wpuser'@'%' IDENTIFIED WITH mysql_native_password BY 'Passw0_rd';" | mysql -u$USER -p$PASS

for s in `ls -1 $DIR`;
    do
    echo "--> $s restoring... ";
    zcat $DIR/$s | /usr/bin/mysql --user=$USER --password=$PASS $DB &
    done

echo "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'%';" | mysql --user=$USER --password=$PASS
echo "FLUSH PRIVILEGES;" | mysql --user=$USER --password=$PASS

rm -r /root/mysql-m/wpdb*

echo "Recovery completed!"

