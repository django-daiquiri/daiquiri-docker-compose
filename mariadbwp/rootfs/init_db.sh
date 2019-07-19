#!/bin/sh

mysql -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE wordpress;*.* to '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD';""
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE wordpress;
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "flush privileges;"