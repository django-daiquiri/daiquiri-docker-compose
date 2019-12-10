#!/bin/bash

if [[ ! -f "${VE}/bin/activate" ]]; then
    cd "${VOL}" || exit 1
    echo "Creating virtual enviroment ve in ${VOL}"
    virtualenv -p python3 ve
fi
source "${VE}/bin/activate"
if [[ -d "${VOL}/daiquiri/${DAIQUIRI_APP}" ]]; then
  echo "Changing into ${VOL}/daiquiri/${DAIQUIRI_APP}"
  cd "${VOL}/daiquiri/${DAIQUIRI_APP}" || exit 1
fi
