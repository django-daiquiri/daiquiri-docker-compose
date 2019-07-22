#!/bin/bash

# Daiquiri theme and plugin
cd /var/www/html/wp-content/plugins/ && \
     git clone https://github.com/django-daiquiri/wordpress-plugin daiquiri && \
     cd /var/www/html/wp-content/themes && \
     git clone https://github.com/django-daiquiri/wordpress-theme daiquiri

# should come from env file but doesn't
# WORDPRESS_CONFIG_EXTRA=define('DAIQUIRI_URL', 'localhost:9494');
#addconfig="// DAIQUIRI URL\n$WORDPRESS_CONFIG_EXTRA"
#sed "/define('WP_DEBUG'"/a"$addconfig" /var/www/html/wp-config.php > ./tmp.php
#cp ./tmp.php /var/www/html/wp-config.php /var/www/html/wp-config.php


# cat /var/www/wp-config.php | grep EXTRA

while true; do
    apachectl -D FOREGROUND
    sleep 10
done