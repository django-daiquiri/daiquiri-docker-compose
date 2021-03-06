#!/bin/bash

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${scriptdir}/source.sh"


cd "${VOL}/wp" || exit 1

# install wordpress
if [[ ! -f wp-config.php ]]; then
    echo 'no wordpress found'
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz
    mv wordpress/* ./
    rm latest.tar.gz
    rm -R wordpress
fi

# wordpress config setup
maybe_copy "/tmp/wp-config-sample.php" "${VOL}/wp/wp-config.php"

# replace_in_wpconfig "DAIQUIRI_URL" "http://$(get_container_ip "dq-daiquiri")"
replace_in_wpconfig "DAIQUIRI_URL" "http://localhost:80"
replace_in_wpconfig "WP_HOME" "http://localhost:${FINALLY_EXPOSED_PORT}/cms"
replace_in_wpconfig "WP_SITEURL" "http://localhost:${FINALLY_EXPOSED_PORT}/cms"

# daiquiri theme and plugin
clone https://github.com/django-daiquiri/wordpress-plugin ./wp-content/plugins/daiquiri
clone https://github.com/django-daiquiri/wordpress-theme ./wp-content/themes/daiquiri

# setup WordPress
sudo chown -R daiquiri:apache "${VOL}/wp"
sudo chmod -R u=rwx,g=rwx "${VOL}/wp"
cd "${VOL}/wp"
sudo mkdir wp-content/menus
sudo chown daiquiri:apache wp-content/menus
sudo chmod 775 wp-content/menus

