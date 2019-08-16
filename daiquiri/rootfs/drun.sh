#!/bin/bash

# create log directories
mkdir -p ${VOL}/log/gunicorn/
touch ${VOL}/log/gunicorn/access.log
mkdir -p ${VOL}/log/daiquiri/
mkdir -p ${VOL}/log/httpd/


/opt/install-daiquiri.sh

/opt/install-wp.sh


cd /vol/daiquiri/${DAIQUIRI_APP}
gunicorn --bind localhost:9001 \
        --log-file=/vol/log/gunicorn/gunicorn.log \
        --access-logfile=/vol/log/gunicorn/access.log \
        --workers 2 \
        config.wsgi:application -D 

while true; do 
    /usr/sbin/httpd -D FOREGROUND
    sleep 10
done 