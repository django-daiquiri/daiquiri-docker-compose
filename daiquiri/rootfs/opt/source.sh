
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
