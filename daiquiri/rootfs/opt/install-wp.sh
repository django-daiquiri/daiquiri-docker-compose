#!/bin/bash

cd ${VOL}/wp

if [ ! -e wp-config.php ]; then

    echo 'no wordpress found'
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz
    mv wordpress/* ./
    rm latest.tar.gz
    rm -R wordpress

    # copy prepared config files
fi

if [[ ! -f ./wp-config.php ]]; then
    cp /tmp/wp-config-sample.php ./wp-config.php
fi

# Daiquiri theme and plugin
git clone https://github.com/django-daiquiri/wordpress-plugin ./wp-content/plugins/daiquiri
git clone https://github.com/django-daiquiri/wordpress-theme ./wp-content/themes/daiquiri

chmod 755 /vol/wp
chown -R apache:apache ${VOL}/wp
