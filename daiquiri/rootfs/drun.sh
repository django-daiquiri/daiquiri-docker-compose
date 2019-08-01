#!/bin/bash

/opt/install-daiquiri.sh

mkdir -p /vol/log/nginx/

while true; do
    cd /vol/daiquiri/${DAIQUIRI_APP}
    gunicorn --bind unix:/var/run/daiquiri.sock config.wsgi:application -D
    
    nginx -g "daemon off;"
    sleep 10
done
