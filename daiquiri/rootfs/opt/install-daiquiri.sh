  #!/bin/bash

echo "su daiquiri"
whoami
su daiquiri
whoami
# clone app 
echo "***GIT CLONE APP***"
git clone -b dev ${DAIQUIRI_APP_REPO} ${VOL}/daiquiri/${DAIQUIRI_APP}

# activate environment
source /opt/ve.sh
cp -f /tmp/template_local.py ${VOL}/daiquiri/${DAIQUIRI_APP}/config/settings/local.py

pip3 install --upgrade pip
pip3 install gunicorn

if [[ $(pip3 freeze | grep -Poc "django-daiquiri") == "0" ]]; then

    # Get repos
    git clone -b dev ${DAIQUIRI_REPO} ${VOL}/daiquiri/source

    pip3 install --upgrade wheel
    pip3 install --upgrade setuptools
    pip3 install psycopg2-binary
    pip3 install astropy

    # mkdir -p ${VOL}/daiquiri/${DAIQUIRI_APP}/config
    # cp -f /tmp/wsgi.py ${VOL}/daiquiri/${DAIQUIRI_APP}/wsgi.py

    # pip installs
    cd ${VOL}/daiquiri/${DAIQUIRI_APP}
    pip3 install -e ${VOL}/daiquiri/source
    cp -f /tmp/template_local.py ${VOL}/daiquiri/${DAIQUIRI_APP}/config/settings/local.py
    python3 ./manage.py makemigrations
    python3 manage.py migrate
    mkdir -p ${VOL}/daiquiri/${DAIQUIRI_APP}/vendor
    python3 manage.py download_vendor_files
    python3 manage.py collectstatic 

else
    echo "Daiquiri is already installed."
fi

