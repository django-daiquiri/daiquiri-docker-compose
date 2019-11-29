#!/bin/bash

source "${HOME}/.bashrc"

# create log directories
mkdir -p "${VOL}/log/gunicorn"
touch "${VOL}/log/gunicorn/access.log"
mkdir -p "${VOL}/log/daiquiri"
mkdir -p "${VOL}/log/httpd"

/opt/install-wp.sh
/opt/install-daiquiri.sh

cd "${VOL}/daiquiri/${DAIQUIRI_APP}" || exit 1

sudo mkdir -p "/etc/httpd/vhosts.d"
maybe_copy "/tmp/vhost2.conf" "/etc/httpd/vhosts.d/vhost2.conf" "sudo"
maybe_copy "/tmp/wsgi.py" "${VOL}/daiquiri/${DAIQUIRI_APP}/config/wsgi.py" "sudo"

replace_ip_in_vhost

if [[ "$(does_run "gunicorn")" == "false" ]]; then
    gunicorn --bind 0.0.0.0:9001 \
        --log-file=/vol/log/gunicorn/gunicorn.log \
        --access-logfile=/vol/log/gunicorn/access.log \
        --workers 2 \
        config.wsgi:application -D
fi

sudo rm -f /var/run/httpd/*.pid
sudo /usr/sbin/httpd -D FOREGROUND
