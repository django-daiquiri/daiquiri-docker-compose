# Django-Daiquiri Docker Compose

## Synopsis

This repository contains development setup for the django-daiquiri application. [docker compose](https://github.com/docker/compose/releases) is required to run the containers. If not configured differently the built Daiquiri instance should be available at `localhost:9494`. Please see below how setting can be changed.

## How to start

The setup should be run as local user. The user should have the privileges to run docker on the local system - add the user to the `docker` group.  

How to use make:
```bash
    git clone https://github.com/django-daiquiri/daiquiri-docker-compose/
    cd daiquiri-docker-compose/
    make                # prepare settings, build and run the docker container
```
See more details in the **Configuration and Usage** below. 

### Dockers
FOUR containers are going to be created running, `daiquiri` and the database dockers.

### Volumes
During build four folders later used as volumes will be created in `vol/`. They contain the following:

* `daiquiri` daiquiri installation
* `wp` Wordpress installation
* `log` log files
* `download` download files
* `files` files directory
* `ve` python's virtual environment
* `postgres-app` daiquiri application database
* `postgres-data` data database
* `wpdb` Wordpress database

## Configuration and usage
1. Declare your settings in `*.local`

    Default settings are stored in the `settings/` folder. all `*.env` files are overwritten with each pull. To keep the local changes, copy `settings/app.env` file to `settings/app.local` and edit it. Same goes for the 
    DB settings in `var/postgresapp.env` and `var/postgresdata.env`
    ```shell
        cd settings
        cp app.env app.local    #settings for the app: URL, DB access, etc.
        cp postgresapp.env postgressapp.local # daiquiri app DB settings
        cp postgredata.env postgresdata.local # daiquiri data DB settings
    ```
    The `makefile` will use the `*local*` file if such a file exists. 

    Replace <DOCKERHOST> in the `var/app.local` file with the name of your host or the url which is supposed to serve daiquiri instance.

1. Run!

    Run the make script will set the settings to the docker-compose master file and config files, build and run the dockers. 

    ```
        make                # prepare settings, build and run the docker container
        make preparations   # fill in the local settings into the docker compose, etc.
        make down           # stop the container, remove the volumes
    ```

1. Connect to the daiquiri container

    ```shell
    # connect to the docker
    docker exec -ti dq-daiquiri bash
    ```

    Now you can use the terminal as on any other machine.

1. Install the Wordpress instance
    Install the Wordpress instance via`localhost:9494/cms/wp-admin/`. Activate the Daiquiri plugin and choose the Daiquir theme 
            
1. Create daiquiri superuser
    Inside the docker container activate the virtual env:
    
    ```shell
    # connect to the docker
    docker exec -ti dq-daiquiri bash
    
    # now in the docker bash
    ./manage.py createsuperuser
    
    # or for testing purposes create default admin user
    ./manage.py create_admin_user
    ```
    Follow the steps to create a superuser or create a default admin user for testing purposes. The admin user should not be used in productive setup.
        
    
1. Usefull commands on the docker host
```
    docker-compose -f ./docker-compose.yaml up --build -d
    docker-compose logs -f
    docker-compose -f ./docker-wptest.yaml down -v  
```

The -v option removes the volumes. Try with `sudo` if it doesn't work. 

```
    docker container ps -aq | xargs docker stop
    docker container ps -aq | xargs docker rm
    docker volume ls |  xargs docker volume rm 
```

1. Docker armageddon
If the docker on your system (mis)behaves strangely, use following script to end all of it. Stop and start the docker service in the end. 

**WARNING: do not use it on your productive system**
```bash
    docker stop $(sudo docker ps -aq)
    docker rm $(sudo docker ps -aq)
    docker network prune -f
    docker rmi -f $(sudo docker images --filter dangling=true -qa)
    docker volume rm $(sudo docker volume ls --filter dangling=true -q)
    docker rmi -f $(sudo docker images -qa)
```

## Multiple Daiquiri instances on a single docker host
You can have multiple running Daiquiri instances on a single docker host as long as you pay attention to three things.

1. Use different folders containing the Daiquiri `docker-compose` repo to make sure docker-compose considers your build attempts to be different projects. Unfortunately currently there is no manual configuration for this because the `COMPOSE_PROJECT_NAME` option seems to be broken.
1. Make sure to use different `GLOBAL_PREFIX` settings in your `var/app.local` to avoid conflicts between your docker containers and volumes.
1. And obviously change the `FINALLY_EXPOSED_PORT` settings to make sure to use a free port to expose Daiquiri.
