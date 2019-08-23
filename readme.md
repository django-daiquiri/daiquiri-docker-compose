# Django-Daiquiri Docker Compose

## Synopsis

This repository contains development setup for the django-daiquiri application. [docker compose](https://github.com/docker/compose/releases) is required to run the containers. If not configured differently the built Daiquiri instance should be available at `localhost:9494`. Please see below how setting can be changed.


## Structure
### Dockers
FOUR containers are going to be created running, `daiquiri` and the database dockers. 

### Volumes
During build four folders later used as volumes will be created under `vol/`. They contain the following:

* `daiquiri` daiquiri installation 
* `log` log files
* `download` download files
* `postgres-app` database
* `postgres-data` database
* `ve` python's virtual environment


## Configuration & Usage
1. Declare your settings in `*.local`

    Default settings are stored in the `var/` folder. all `*.env` files are overwritten with each pull. To keep the local changes, copy `var/app.env` file to `var/app.local` and edit it. Same goes for the DB settings in `var/postgresapp.env` and `var/postgresdata.env`

    The `makefile` will use the `*.local` file if such a file exists. 
1. Copy `var/app.env` to `var/app.local`. Replace <DOCKERHOST> in the `var/app.local` file with the name of your host or the url which is supposed to serve daiquiri instance. 
    
1. Create a superuser for the Daiquiri instance
    
    ```shell
    # connect to the docker
    docker exec -ti daiquiri bash
    cd /vol/daiquiri/app
    .manage.py createsuperuser
    ```
    Follow the steps to create a superuser.

    NOTICE: the email verification is set to optional (see "config/settings/local.py")
    ```
    # switch off email verification
    ACCOUNT_EMAIL_VERIFICATION = 'optional'
    ```
1. Usefull commands
```
docker-compose -f ./docker-compose.yaml up --build -d
docker-compose logs -f
docker-compose -f ./docker-wptest.yaml down -v  
```
The -v option removes the volumes.

```
sudo docker container ps -aq | xargs sudo docker stop
sudo docker container ps -aq | xargs sudo docker rm
sudo docker volume ls | sudo xargs docker volume rm 
```


## Multiple Daiquiri instances on a single docker host
You can have multiple running Daiquiri instances on a single docker host as long as you pay attention to three things.

1. Use different folders containing the Daiquiri `docker-compose` repo to make sure docker-compose considers your build attempts to be different projects. Unfortunately currently there is no manual configuration for this because the `COMPOSE_PROJECT_NAME` option seems to be broken.
1. Make sure to use different `GLOBAL_PREFIX` settings in your `var/app.local` to avoid conflicts between your docker containers and volumes.
1. And obviously change the `FINALLY_EXPOSED_PORT` settings to make sure to use a free port to expose Daiquiri.
