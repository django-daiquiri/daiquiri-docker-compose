#!/bin/bash

if [[ ! -f "${VE}/bin/activate" ]]; then
    cd "${VOL}" || exit 1
    echo "Creating virtual enviroment ve in ${VOL}"
    virtualenv -p python3 ve
fi
source "${VE}/bin/activate"
if [[ -d "${VOL}/app" ]]; then
  echo "Changing into ${VOL}/app"
  cd "${VOL}/app" || exit 1
fi
