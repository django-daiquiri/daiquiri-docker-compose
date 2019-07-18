#!/bin/bash


cp /tmp/wp-config-sample.php /vol/wp/wordpress/wp-config.php


sed -i 's/.*cgi.fix_pathinfo=1.*/cgi.fix_pathinfo=0/' /etc/php.ini

# get plugin and theme
cd /vol/wp/wordpress/wp-content/plugins/ && \
      git clone https://github.com/django-daiquiri/wordpress-plugin daiquiri

cd /vol/wp/wordpress/wp-content/themes && \
      git clone https://github.com/django-daiquiri/wordpress-theme daiquiri


# Adjust user:
#useradd -ms /bin/bash wordpress
# chmod -R nginx:wordpress /vol/wp/wordpress
chown -R nginx:nginx /var/lib/php/session/
cd /vol/wp/

mkdir /run/php-fpm

while true; do
   
    php-fpm
    nginx -c /etc/nginx/nginx.conf -g "daemon off;"
    sleep 10
done