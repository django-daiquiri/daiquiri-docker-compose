#!/bin/bash

function clone(){
    url="${1}"
    fol="${2}"
    if [[ ! -d "${fol}" ]]; then
        echo "Cloning ${url}"
        git clone "${url}" "${fol}"
    else
        echo "Pulling ${url}"
        cd ${fol}
        git pull
    fi
}

function get_container_ip(){
    ping -c 1 "${1}" \
        | grep -Po "([0-9]{1,3}[\.]){3}[0-9]{1,3}" \
        | head -n 1
}

function replace_in_wpconfig(){
    str="${1}"
    rep="${2}"
    wpc="${VOL}/wp/wp-config.php"
    sed -i "s|\('${str}',\s\).*)|\1'${rep}'\)|g" "${wpc}"
}
