if [[ ! -f "${VE}/bin/activate" ]]; then
    cd ${VOL}
    virtualenv -p python3 ve
fi
source ${VE}/bin/activate
cd ${DAIQUIRI_APP}
