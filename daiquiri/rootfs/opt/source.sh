#!/bin/bash

function clone(){
    url="${1}"
    fol="${2}"
    if [[ ! -d "${fol}" ]]; then
        echo "Cloning ${url}"
        git clone "${url}" "${fol}"
    else
        echo "Pulling ${url}"
        cd "${fol}" || exit 1
        git pull
    fi
}

function does_run(){
    r="false"
    if [[ $(ps aux | grep -v "grep" | grep -c "${1}") != "0" ]]; then
        r="true"
    fi
    echo "${r}"
}

function maybe_copy(){
    source_file="${1}"
    target_file="${2}"
    if [[ "${3}" == "sudo" ]]; then
        cmd="sudo cp"
    else
        cmd="cp"
    fi
    if [[ ! -f "${target_file}" ]]; then
        cmd="${cmd} \"${source_file}\" \"${target_file}\""
        echo "${cmd}"
        eval "${cmd}"
    fi
}

function get_container_ip(){
    hostname -I | awk '{print $1}'
}

function replace_in_wpconfig(){
    str="${1}"
    rep="${2}"
    wpc="${VOL}/wp/wp-config.php"
    echo "Replace of file ${wpc}"
    sed -i "s|\('${str}',\s\).*)|\1'${rep}'\)|g" "${wpc}"
}

function replace_ip_in_vhost(){
    dqip="$(get_container_ip):80"
    echo "Replace of file /etc/httpd/vhosts.d/vhost2.conf"
    sudo sed -i "s|http://[.0-9a-z:]*|http://${dqip}|g" "/etc/httpd/vhosts.d/vhost2.conf"
}
