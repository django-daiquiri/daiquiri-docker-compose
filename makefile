CURDIR=$(shell pwd)
DC_MASTER="dc_master.yaml"
DC_TEMP="docker-compose.yaml"

DOCKER_IN_GROUPS=$(shell groups | grep "docker")
MYID=$(shell id -u)

ifeq ($(strip $(DOCKER_IN_GROUPS)),)
	DC_CMD=sudo docker-compose
	D_CMD= sudo docker
else
	DC_CMD=docker-compose
	D_CMD=docker
endif



VARS_ENV=$(shell if [ -f settings/app.local ]; then echo settings/app.local; else echo settings/app.env; fi)
FINALLY_EXPOSED_PORT=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=FINALLY_EXPOSED_PORT=)[0-9]+")
GLOBAL_PREFIX=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=GLOBAL_PREFIX=).*")
QUERY_DOWNLOAD_DIR=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=QUERY_DOWNLOAD_DIR=).*")
ARCHIVE_BASE_PATH=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=ARCHIVE_BASE_PATH=).*")
DAIQUIRI_APP=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=DAIQUIRI_APP=).*")

# Postgres data and app
VARS_DB_APP=$(shell if [ -f settings/postgresapp.local ]; then echo settings/postgresapp.local; else echo settings/postgresapp.env; fi)
POSTGRES_APP_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_APP_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_APP_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_APP_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_APP_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")
PGEXP_APP=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_APP_EXPOSE_PORT=)[0-9]+")
POSTGRES_APP_EXPOSE=$(shell if [ -n "${PGEXP_APP}" ]; then echo "ports:"; else echo ""; fi)
POSTGRES_APP_EXPOSE_PORT=$(shell if [ -n "${PGEXP_APP}" ]; then echo "- \"${PGEXP_APP}:${POSTGRES_APP_PORT}\""; else echo ""; fi)

VARS_DB_DATA=$(shell if [ -f settings/postgresdata.local ]; then echo settings/postgresdata.local; else echo settings/postgresdata.env; fi)
POSTGRES_DATA_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_DATA_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_DATA_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_DATA_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_DATA_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")
PGEXP_DATA=$(shell cat ${CURDIR}/${VARS_DB_DATA} | grep -Po "(?<=POSTGRES_DATA_EXPOSE_PORT=)[0-9]+")
POSTGRES_DATA_EXPOSE=$(shell if [ -n "${PGEXP_DATA}" ]; then echo "ports:"; else echo ""; fi)
POSTGRES_DATA_EXPOSE_PORT=$(shell if [ -n "${PGEXP_DATA}" ]; then echo "- \"${PGEXP_DATA}:${POSTGRES_DATA_PORT}\""; else echo ""; fi)

# WP
WORDPRESS_DB_USER=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=WORDPRESS_DB_USER=).*")
WORDPRESS_DB_NAME=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=WORDPRESS_DB_NAME=).*")
WORDPRESS_DB_PASSWORD=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=WORDPRESS_DB_PASSWORD=).*")
WORDPRESS_DB_HOST=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=WORDPRESS_DB_HOST=).*")
DAIQUIRI_URL=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=DAIQUIRI_URL=).*")
WORDPRESS_URL=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=WORDPRESS_URL=).*")
HTTP_HOST=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=HTTP_HOST=).*")
SITE_URL=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=SITE_URL=).*")
DOCKERHOST=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=DOCKERHOST=).*")
VARS_WP=$(shell if [ -f settings/wp.local ]; then echo settings/wp.local; else echo settings/wp.env; fi)

all: root_check render_yaml preparations run_build tail_logs
build: render_yaml preparations run_build
fromscratch: render_yaml preparations run_remove run_build
remove: run_remove
restart: run_restart
down: run_down
logs: tail_logs
yaml: render_yaml

root_check:
			@if [ "${MYID}" = "0" ]; then \
				echo Do not run as root. Conflicting file permissions will not allow it.; \
			fi
			@exit

render_yaml:
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
		| sed 's|<QUERY_DOWNLOAD_DIR>|${QUERY_DOWNLOAD_DIR}|g' \
		| sed 's|<ARCHIVE_BASE_PATH>|${ARCHIVE_BASE_PATH}|g' \
		| sed 's|<POSTGRES_APP_EXPOSE>|${POSTGRES_APP_EXPOSE}|g' \
		| sed 's|<POSTGRES_APP_EXPOSE_PORT>|${POSTGRES_APP_EXPOSE_PORT}|g' \
		| sed 's|<POSTGRES_DATA_EXPOSE>|${POSTGRES_DATA_EXPOSE}|g' \
		| sed 's|<POSTGRES_DATA_EXPOSE_PORT>|${POSTGRES_DATA_EXPOSE_PORT}|g' \
		> ${DC_TEMP}

preparations:
	mkdir -p ${CURDIR}/vol/postgres-app
	mkdir -p ${CURDIR}/vol/postgres-data
	mkdir -p ${CURDIR}/vol/daiquiri
	mkdir -p ${CURDIR}/vol/download
	mkdir -p ${CURDIR}/vol/files
	mkdir -p ${CURDIR}/vol/ve
	mkdir -p ${CURDIR}/vol/wp
	mkdir -p ${CURDIR}/vol/wpdb

	# create log directories
	mkdir -p ${CURDIR}/vol/log

	# Reverse proxy nginx conf
	mkdir -p ${CURDIR}/nginx_rp/tmp
	cat ${CURDIR}/nginx_rp/conf/server.conf \
	  | sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
	  | sed 's|<FINALLY_EXPOSED_PORT>|${FINALLY_EXPOSED_PORT}|g' \
	  | sed 's|<DAIQUIRI_APP>|${DAIQUIRI_APP}|g' \
	 > ${CURDIR}/nginx_rp/tmp/server.conf

	 # set user id in daiquiri dockerfile
	 cat ${CURDIR}/daiquiri/dockerfile_master \
	    	| sed 's|<UID>|$(MYID)|g' \
	    	> ${CURDIR}/daiquiri/dockerfile


	mkdir -p ${CURDIR}/daiquiri/rootfs/tmp
	# httpd
	cat ${CURDIR}/daiquiri/conf/httpd.conf \
		| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
	> ${CURDIR}/daiquiri/rootfs/tmp/httpd.conf

	# vhost
	cat ${CURDIR}/daiquiri/conf/vhost.conf \
		| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
		| sed 's|<DAIQUIRI_APP>|${DAIQUIRI_APP}|g' \
		| sed 's|<SITE_URL>|${SITE_URL}|g' \
	> ${CURDIR}/daiquiri/rootfs/tmp/vhost.conf

	# vhost2
	cat ${CURDIR}/daiquiri/conf/vhost2.conf \
		| sed 's|<FINALLY_EXPOSED_PORT>|${FINALLY_EXPOSED_PORT}|g' \
		> ${CURDIR}/daiquiri/rootfs/tmp/vhost2.conf
	cp -f \
		"${CURDIR}/daiquiri/conf/wsgi.py" \
		"${CURDIR}/daiquiri/rootfs/tmp/wsgi.py"

	# Wordpress
	cat ${CURDIR}/daiquiri/conf/wp-config-sample.php \
		| sed 's|<WORDPRESS_URL>|"${WORDPRESS_URL}"|g' \
		| sed 's|<SITE_URL>|"${SITE_URL}"|g' \
		| sed 's|<HTTP_HOST>|"${HTTP_HOST}"|g' \
		| sed 's|<GLOBAL_PREFIX>|"${GLOBAL_PREFIX}"|g' \
		| sed 's|<WORDPRESS_DB_NAME>|"${WORDPRESS_DB_NAME}"|g' \
		| sed 's|<WORDPRESS_DB_USER>|"${WORDPRESS_DB_USER}"|g' \
		| sed 's|<WORDPRESS_DB_HOST>|"${WORDPRESS_DB_HOST}"|g' \
		| sed 's|<WORDPRESS_DB_PASSWORD>|"${WORDPRESS_DB_PASSWORD}"|g' \
		> ${CURDIR}/daiquiri/rootfs/tmp/wp-config-sample.php

	# make a rule for firewall
	# /sbin/iptables -A INPUT -i docker0 -j ACCEPT
	# to be tested with firewalld
	# firewall-cmd --permanent --zone=trusted --change-interface=docker0

run_build:
	$(DC_CMD) up --build -d

run_volrm:
	$(D_CMD) volume ls | xargs $(D_CMD) volume rm

run_down:
	$(DC_CMD) -f ./docker-compose.yaml down -v

run_remove:
	$(DC_CMD) down
	$(DC_CMD) down -v
	$(DC_CMD) rm --force

tail_logs:
	$(DC_CMD) logs -f

run_restart:
	$(DC_CMD) restart
