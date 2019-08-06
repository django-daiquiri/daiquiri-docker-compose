CURDIR=$(shell pwd)
DC_MASTER="dc_master.yaml"
DC_TEMP="docker-compose.yaml"

VARS_ENV=$(shell if [ -f settings/app.local ]; then echo settings/app.local; else echo settings/app.env; fi)
FINALLY_EXPOSED_PORT=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=FINALLY_EXPOSED_PORT=)[0-9]+")
GLOBAL_PREFIX=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=GLOBAL_PREFIX=).*")
DOWNLOAD_DIR=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=DOWNLOAD_DIR=).*")
DAIQUIRI_APP=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=DAIQUIRI_APP=).*")

TMP_LOCAL_MASTER = "daiquiri/rootfs/tmp/template_local.py.tmp"
TMP_LOCAL = "daiquiri/rootfs/tmp/template_local.py"

# Postgres data and app
VARS_DB_APP=$(shell if [ -f settings/postgresapp.local ]; then echo settings/postgresapp.local; else echo settings/postgresapp.env; fi)
POSTGRES_APP_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_APP_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_APP_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_APP_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_APP_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")
VARS_DB_DATA=$(shell if [ -f settings/postgresdata.local ]; then echo settings/postgresdata.local; else echo settings/postgresdata.env; fi)
POSTGRES_DATA_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_DATA_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_DATA_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_DATA_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_DATA_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")

# WP
VARS_WP=$(shell if [ -f settings/wp.local ]; then echo settings/wp.local; else echo settings/wp.env; fi)
WORDPRESS_DB_USER=$(shell cat ${CURDIR}/${VARS_WP} | grep -Po "(?<=WORDPRESS_DB_USER=).*")
WORDPRESS_DB_NAME=$(shell cat ${CURDIR}/${VARS_WP} | grep -Po "(?<=WORDPRESS_DB_NAME=).*")
WORDPRESS_DB_PASSWORD=$(shell cat ${CURDIR}/${VARS_WP} | grep -Po "(?<=WORDPRESS_DB_PASSWORD=).*")
WORDPRESS_DB_HOST=$(shell cat ${CURDIR}/${VARS_WP} | grep -Po "(?<=WORDPRESS_DB_HOST=).*")
DAIQUIRI_URL=$(shell cat ${CURDIR}/${VARS_WP} | grep -Po "(?<=DAIQUIRI_URL=).*")

all: preparations run_build tail_logs
build: preparations run_build
fromscratch: preparations run_remove run_build
remove: run_remove

preparations:
	mkdir -p ${CURDIR}/vol/postgres-app
	mkdir -p ${CURDIR}/vol/postgres-data
	mkdir -p ${CURDIR}/vol/daiquiri
	mkdir -p ${CURDIR}/vol/download
	mkdir -p ${CURDIR}/vol/ve
	mkdir -p ${CURDIR}/vol/wp
	mkdir -p ${CURDIR}/vol/wpdb

	# create log directories
	mkdir -p ${CURDIR}/vol/log
	# chmod 777 -R ${CURDIR}/vol/log

	# rewrite docker-compose.yaml
	cat ${DC_MASTER} \
		| sed 's|<HOME>|${HOME}|g' \
		| sed 's|<CURDIR>|${CURDIR}|g' \
		| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
		| sed 's|<FINALLY_EXPOSED_PORT>|${FINALLY_EXPOSED_PORT}|g' \
		| sed 's|<VARIABLES_FILE>|${VARS_ENV}|g' \
		| sed 's|<VARIABLES_DB_APP>|${VARS_DB_APP}|g' \
		| sed 's|<VARIABLES_DB_DATA>|${VARS_DB_DATA}|g' \
		| sed 's|<VARIABLES_WP>|${VARS_WP}|g' \
		| sed 's|<DOWNLOAD_DIR>|${DOWNLOAD_DIR}|g' \
		> ${DC_TEMP}

	# rewrite settings in local.py for Daiquiri
	cat ${TMP_LOCAL_MASTER} \
		| sed 's|<GLOBAL_PREFIX>|"${GLOBAL_PREFIX}"|g' \
		| sed 's|<POSTGRES_APP_DB>|"${POSTGRES_APP_DB}"|g' \
		| sed 's|<POSTGRES_APP_USER>|"${POSTGRES_APP_USER}"|g' \
		| sed 's|<POSTGRES_APP_PASSWORD>|"${POSTGRES_APP_PASSWORD}"|g' \
		| sed 's|<POSTGRES_APP_HOST>|"${POSTGRES_APP_HOST}"|g' \
		| sed 's|<POSTGRES_APP_PORT>|"${POSTGRES_APP_PORT}"|g' \
		| sed 's|<POSTGRES_DATA_DB>|"${POSTGRES_DATA_DB}"|g' \
		| sed 's|<POSTGRES_DATA_USER>|"${POSTGRES_DATA_USER}"|g' \
		| sed 's|<POSTGRES_DATA_PASSWORD>|"${POSTGRES_DATA_PASSWORD}"|g' \
		| sed 's|<POSTGRES_DATA_HOST>|"${POSTGRES_DATA_HOST}"|g' \
		| sed 's|<POSTGRES_DATA_PORT>|"${POSTGRES_DATA_PORT}"|g' \
		| sed 's|<DOWNLOAD_DIR>|"${DOWNLOAD_DIR}"|g' \
		> ${TMP_LOCAL}

	# Daiquiri nginx conf 
	cat ${CURDIR}/daiquiri/rootfs/etc/nginx/conf.d/vhosts.conf.tmp \
	| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
	| sed 's|<DAIQUIRI_APP>|${DAIQUIRI_APP}|g' \
	> ${CURDIR}/daiquiri/rootfs/etc/nginx/conf.d/vhosts.conf

	# Reverse proxy nginx conf 
	cat ${CURDIR}/nginx/conf/vhost.conf.tmp \
	| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
	> ${CURDIR}/nginx/conf/vhost.conf



	# Wordpress
	# apache2
	cat ${CURDIR}/wordpress/rootfs/tmp/vhost.conf \
	| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
	> ${CURDIR}/wordpress/rootfs/etc/apache2/sites-available/vhost.conf

	# wp-config.php
	cat ${CURDIR}/wordpress/rootfs/tmp/wp-config-sample.tmp.php \
		| sed 's|<DAIQUIRI_URL>|"${DAIQUIRI_URL}"|g' \
		| sed 's|<GLOBAL_PREFIX>|"${GLOBAL_PREFIX}"|g' \
		| sed 's|<WORDPRESS_DB_NAME>|"${WORDPRESS_DB_NAME}"|g' \
		| sed 's|<WORDPRESS_DB_USER>|"${WORDPRESS_DB_USER}"|g' \
		| sed 's|<WORDPRESS_DB_HOST>|"${WORDPRESS_DB_HOST}"|g' \
		| sed 's|<WORDPRESS_DB_PASSWORD>|"${WORDPRESS_DB_PASSWORD}"|g' \
		> ${CURDIR}/wordpress/rootfs/tmp/wp-config-sample.php
	
run_build:
	docker-compose up --build -d

run_volrm:
	docker volume ls | xargs sudo docker volume rm 

run_remove:
	docker-compose down --rmi all 
	docker-compose down -v
	docker-compose rm --force

tail_logs:
	docker-compose logs -f
