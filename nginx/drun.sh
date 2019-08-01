#!/bin/bash

# make a log dir
mkdir -p /vol/log/proxy

while true; do
   
    nginx -c "/etc/nginx/nginx.conf" -g "daemon off;"
    sleep 10
done
