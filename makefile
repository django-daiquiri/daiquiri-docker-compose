CURDIR=$(shell pwd)
DC_MASTER="dc_master.yaml"
DC_TEMP="docker-compose.yaml"

VARS_ENV=$(shell if [ -f var/app.local ]; then echo var/app.local; else echo var/app.env; fi)
FINALLY_EXPOSED_PORT=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=FINALLY_EXPOSED_PORT=)[0-9]+")
GLOBAL_PREFIX=$(shell cat ${CURDIR}/${VARS_ENV} | grep -Po "(?<=GLOBAL_PREFIX=).*")

TMP_LOCAL_MASTER = "daiquiri/rootfs/tmp/template_local.py.tmp"
TMP_LOCAL = "daiquiri/rootfs/tmp/template_local.py"

VARS_DB_APP=$(shell if [ -f var/postgresapp.local ]; then echo var/postgresapp.local; else echo var/postgresapp.env; fi)
POSTGRES_APP_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_APP_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_APP_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_APP_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_APP_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")
VARS_DB_DATA=$(shell if [ -f var/postgresdata.local ]; then echo var/postgresdata.local; else echo var/postgresdata.env; fi)
POSTGRES_DATA_DB=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_DB=).*")
POSTGRES_DATA_USER=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_USER=).*")
POSTGRES_DATA_PASSWORD=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PASSWORD=).*")
POSTGRES_DATA_HOST=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_HOST=).*")
POSTGRES_DATA_PORT=$(shell cat ${CURDIR}/${VARS_DB_APP} | grep -Po "(?<=POSTGRES_PORT=)[0-9]+")


all: preparations run_build tail_logs
build: preparations run_build
fromscratch: preparations run_remove run_build
remove: run_remove

preparations:
	mkdir -p ${CURDIR}/vol/log
	mkdir -p ${CURDIR}/vol/postgres-app
	mkdir -p ${CURDIR}/vol/postgres-data
	mkdir -p ${CURDIR}/vol/daiquiri-app
	mkdir -p ${CURDIR}/vol/download
	mkdir -p ${CURDIR}/vol/ve

	cat ${DC_MASTER} \
		| sed 's|<HOME>|${HOME}|g' \
		| sed 's|<CURDIR>|${CURDIR}|g' \
		| sed 's|<GLOBAL_PREFIX>|${GLOBAL_PREFIX}|g' \
		| sed 's|<FINALLY_EXPOSED_PORT>|${FINALLY_EXPOSED_PORT}|g' \
		| sed 's|<VARIABLES_FILE>|${VARS_ENV}|g' \
		| sed 's|<VARIABLES_DB_APP>|${VARS_DB_APP}|g' \
		| sed 's|<VARIABLES_DB_DATA>|${VARS_DB_DATA}|g' \
		> ${DC_TEMP}

	cat ${TMP_LOCAL_MASTER} \
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
			> ${TMP_LOCAL}

run_build:
	sudo docker-compose up --build -d

run_remove:
	sudo docker-compose down --rmi all
	sudo docker-compose rm --force

tail_logs:
	sudo docker-compose logs -f
