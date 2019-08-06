#!/bin/bash

# create log directories
mkdir -p /vol/log/nginx/
mkdir -p /vol/log/daiquiri/

/opt/install-daiquiri.sh

while true; do
    cd /vol/daiquiri/${DAIQUIRI_APP}
    gunicorn --bind unix:/var/run/daiquiri.sock config.wsgi:application -D
    
    nginx -g "daemon off;"
    sleep 10
done
