#!/bin/bash

# create log directories
mkdir -p /vol/log/gunicorn/
touch /vol/log/gunicorn/gunicorn-access.log
mkdir -p /vol/log/daiquiri/

/opt/install-daiquiri.sh

cd /vol/daiquiri/${DAIQUIRI_APP}

exec gunicorn --bind 0.0.0.0:9001 \
        --log-file=/vol/log/gunicorn/gunicorn.log \
        --access-logfile=/vol/log/gunicorn/access.log \
        --workers 2 \
        config.wsgi:application 
