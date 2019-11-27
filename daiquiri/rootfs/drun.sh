#!/bin/bash

source ${HOME}/.bashrc

# create log directories
mkdir -p ${VOL}/log/gunicorn/
touch ${VOL}/log/gunicorn/access.log
mkdir -p ${VOL}/log/daiquiri/
mkdir -p ${VOL}/log/httpd/

/opt/install-wp.sh

/opt/install-daiquiri.sh

cd /vol/daiquiri/${DAIQUIRI_APP}

maybe_copy "/tmp/vhost2.conf" "/etc/httpd/vhosts.d/vhost2.conf"
replace_ip_in_vhost


gunicorn --bind 0.0.0.0:9001 \
    --log-file=/vol/log/gunicorn/gunicorn.log \
    --access-logfile=/vol/log/gunicorn/access.log \
    --workers 2 \
    config.wsgi:application -D

while true; do
    sudo rm -f /var/run/httpd/*.pid
    sudo DQIP=${DQIP} /usr/sbin/httpd -D FOREGROUND
    sleep 10
done
