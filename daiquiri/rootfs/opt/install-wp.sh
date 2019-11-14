#!/bin/bash

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${scriptdir}/source.sh"


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
    ip=$(
        ping -c 1 dq-daiquiri \
            | grep -Po "([0-9]{1,3}[\.]){3}[0-9]{1,3}" \
            | head -n 1
    )
    sed -i "s/<DAIQUIRI_CONTAINER_IP>/${ip}/g" ./wp-config.php
fi

# Daiquiri theme and plugin

clone https://github.com/django-daiquiri/wordpress-plugin ./wp-content/plugins/daiquiri
clone https://github.com/django-daiquiri/wordpress-theme ./wp-content/themes/daiquiri

chmod 755 /vol/wp
chown -R apache:apache ${VOL}/wp
