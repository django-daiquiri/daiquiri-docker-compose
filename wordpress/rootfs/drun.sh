#!/bin/bash

mkdir -p /var/www/html/wordpress
cd /var/www/html/wordpress

if [ ! -e config.php ]; then
    
    echo 'no wordpress found'
    echo 'copy from /usr/scr/wordpress'
    # wget https://wordpress.org/latest.tar.gz
    # tar xzvf latest.tar.gz 
    # mv wordrpres/* ./
    # rm latest.tar.gz
    # rm -R wordpress
    cp -R /usr/src/wordpress/* ./
    
    # copy prepared config files
    cp /tmp/wp-config-sample.php ./wp-config.php
fi

# Daiquiri theme and plugin
git clone https://github.com/django-daiquiri/wordpress-plugin ./wp-content/plugins/daiquiri
git clone https://github.com/django-daiquiri/wordpress-theme ./wp-content/themes/daiquiri

chown -R www-data:www-data /var/www/html/wordpress

mkdir -p /vol/log/wp

# should come from env file but doesn't
# WORDPRESS_CONFIG_EXTRA=define('DAIQUIRI_URL', 'localhost:9494');
# addconfig="// DAIQUIRI URL\n$WORDPRESS_CONFIG_EXTRA"
# sed "/define('WP_DEBUG'"/a"$addconfig" /var/www/html/wp-config.php > ./tmp.php
# cp ./tmp.php /var/www/html/wp-config.php /var/www/html/wp-config.php

# cat /var/www/wp-config.php | grep EXTRA

while true; do
    apachectl -D FOREGROUND
    sleep 10
done