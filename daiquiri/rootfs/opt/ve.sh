if [[ ! -f "${VE}/bin/activate" ]]; then
    cd ${VOL}
    virtualenv ve
fi
source ${VE}/bin/activate
cd ${DAIQUIRI_APP}
