#!/bin/bash

# create log directories
mkdir -p /vol/log/gunicorn/
touch /vol/log/gunicorn/gunicorn-access.log
mkdir -p /vol/log/daiquiri/

/opt/install-daiquiri.sh

while true; do
    cd /vol/daiquiri/${DAIQUIRI_APP}
    # gunicorn --bind unix:/var/run/daiquiri.sock config.wsgi:application -D 
    gunicorn --bind 0.0.0.0:9001 --log-file=/vol/log/gunicorn/gunicorn.log config.wsgi:application -D
    # --bind=0.0.0.0:8080
    # nginx -g "daemon off;"
    sleep 10
done
