#!/bin/bash

if [[ ! -f "${VE}/bin/activate" ]]; then
    cd "${VOL}" || exit 1
    virtualenv -p python3 ve
fi
source "${VE}/bin/activate"
cd "${VOL}/daiquiri/${DAIQUIRI_APP}" || exit 1
