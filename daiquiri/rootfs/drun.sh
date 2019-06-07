#!/bin/bash

/opt/install-daiquiri.sh

while true; do
    cd /vol/daiquiri-app/app
    gunicorn --bind unix:/var/run/daiquiri.sock config.wsgi:application -D
    
    nginx -g "daemon off;"
    sleep 10
done
