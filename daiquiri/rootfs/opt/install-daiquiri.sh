  #!/bin/bash

source /opt/ve.sh


if [[ $(pip3 freeze | grep -Poc "^daiquiri==") == "0" ]]; then

    # Get repos
    echo "***GIT CLONE***"
    git clone -b dev ${DAIQUIRI_APP_REPO} ${DAIQUIRI_APP}/app
    git clone -b dev ${DAIQUIRI_REPO} ${DAIQUIRI_APP}/daiquiri

    mkdir -p ${DAIQUIRI_APP}/app/config
    cp -f /tmp/wsgi.py ${DAIQUIRI_APP}/app/wsgi.py


    pip3 install --upgrade pip
    pip3 install --upgrade wheel
    pip3 install --upgrade setuptools
    pip3 install psycopg2-binary
    pip3 install astropy

    pip3 install gunicorn
    
    # pip installs
    cd ${DAIQUIRI_APP}/app
    pip3 install -e ${DAIQUIRI_APP}/daiquiri
    cp -f /tmp/template_local.py ${DAIQUIRI_APP}/app/config/settings/local.py
    python3 ./manage.py makemigrations
    python3 manage.py migrate
    mkdir -p ${DAIQUIRI_APP}/app/vendor
    python3 manage.py download_vendor_files
    python3 manage.py collectstatic --no-input

    # build queryparser from dev directory
    # git clone ${QUERYPARSER_REPO} /vol/daiquiri-app/src/queryparser
    # cd ${QUERYPARSER}
    # curl -O  URL /usr/local/lib/ ${ANTLR_URL}
    # cd /vol/daiquiri-app/src/queryparser
    # make
    # pip3 install -e /vol/daiquiri-app/src/queryparser

    # pip install queryparser
    # pip3 install queryparser-python3


  else
      echo "Won't do anything because Daiquiri is already installed."
  fi
