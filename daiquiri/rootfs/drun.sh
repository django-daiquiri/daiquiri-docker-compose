#!/bin/bash

source ${HOME}/.bashrc

# create log directories
mkdir -p ${VOL}/log/gunicorn/
touch ${VOL}/log/gunicorn/access.log
mkdir -p ${VOL}/log/daiquiri/
mkdir -p ${VOL}/log/httpd/

chown -R daiquiri:apache ${VOL}/daiquiri

/opt/install-wp.sh
chown -R daiquiri:apache ${VOL}/wp
chown -R daiquiri:apache ${VOL}/log/daiquiri

/opt/install-daiquiri.sh
chown -R daiquiri:apache ${VOL}/daiquiri

cd /vol/daiquiri/${DAIQUIRI_APP}

vh2c="/etc/httpd/vhosts.d/vhost2.conf"
if [[ ! -f "${vh2c}" ]]; then
    cp "/tmp/vhost2.conf" "${vh2c}"
fi
replace_ip_in_vhost


gunicorn --bind 0.0.0.0:9001 \
    --log-file=/vol/log/gunicorn/gunicorn.log \
    --access-logfile=/vol/log/gunicorn/access.log \
    --workers 2 \
    config.wsgi:application -D

while true; do
    rm -f /var/run/httpd/*.pid
    DQIP=${DQIP} /usr/sbin/httpd -D FOREGROUND
    sleep 10
done
