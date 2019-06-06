#!/bin/bash

/opt/install-daiquiri.sh

while true; do
   gunicorn --bind unix:/vol/daiquiri.sock config.wsgi:application -D
   nginx -g "daemon off;"
   sleep 10
done