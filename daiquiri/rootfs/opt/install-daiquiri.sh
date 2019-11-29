#!/bin/bash

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${scriptdir}/source.sh"


# clone app
clone "${DAIQUIRI_APP_REPO}" "${VOL}/daiquiri/${DAIQUIRI_APP}"

# activate environment
source /opt/ve.sh

pip3 install --upgrade pip
pip3 install gunicorn

if [[ $(pip3 freeze | grep -Poc "django-daiquiri") == "0" ]]; then

    # Get repos
    clone "${DAIQUIRI_REPO}" "${VOL}/daiquiri/source"

    pip3 install --upgrade wheel
    pip3 install --upgrade setuptools
    pip3 install psycopg2-binary
    pip3 install astropy

    # pip installs
    cd "${VOL}/daiquiri/${DAIQUIRI_APP}" || exit 1
    pip3 install -e "${VOL}/daiquiri/source"
    python3 ./manage.py makemigrations
    python3 manage.py migrate
    mkdir -p "${VOL}/daiquiri/${DAIQUIRI_APP}/vendor"
    python3 manage.py download_vendor_files
    python3 manage.py collectstatic

else
    echo "Daiquiri is already installed."
fi
