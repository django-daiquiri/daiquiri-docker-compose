  #!/bin/bash

source /opt/ve.sh

if [[ $(pip freeze | grep -Poc "^daiquiri==") == "0" ]]; then

    mkdir ${DAIQUIRI_APP}/config
    cp -f /tmp/wsgi.py ${DAIQUIRI_APP}/config/wsgi.py

    pip install --upgrade pip
    pip install --upgrade wheel
    pip install --upgrade setuptools
    pip install psycopg2
    pip install astropy

    # Get repos
    echo "***GIT CLONE***"
    git clone -b dev ${DAIQUIRI_APP_REPO} ${DAIQUIRI_APP}/app
    git clone -b dev ${DAIQUIRI_REPO} ${DAIQUIRI_APP}/daiquiri

    # pip installs
    cd ${DAIQUIRI_APP}/app
    echo "***pip install -e daiquiri***"
    pip3 install -e ${DAIQUIRI_APP}/daiquiri
    echo "***cp files***"
    cp -f /tmp/template_local.py ${DAIQUIRI_APP}/app/config/settings/local.py
    echo "***manage.py***"
    python ./manage.py makemigrations
    python manage.py migrate
    mkdir ${DAIQUIRI_APP}/app/vendor
    python manage.py download_vendor_files
    python manage.py collectstatic --no-input

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
