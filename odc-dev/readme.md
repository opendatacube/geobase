odc-dev
=======

Dockerized environment for running datacube tests and notebooks.

Quick start:

1. Run `./build.sh`
2. Adjust `src_dir` and `nb_dir` in `./run.sh` to match your environment
3. Build fresh python environment: `./run.sh rebuild-env`
4. Explore: `./run.sh help`

Make sure that you can run `docker` without `sudo`. This is achieved by
adding your user to `docker` group.

Overview
--------

The idea is to have an environment as rich as sandbox with all the needed test libraries and services also installed. It should be possible to run all the datacube tests within this image, as well as all DEA notebooks, assuming you have access to the copy of the sandbox database.

Datacube and odc-tools are installed in "edit" mode and are pulled into the container from outside using `/src` volume. Similarly notebooks are pulled in via `/nb` volume.

### Docker Structure

This docker is meant to be built locally, rather than being pulled from the docker hub. Docker image is built such that user inside and outside of the docker match. This is important for developer focused image as it allows to share files more easily between host and the virtual environment.

#### Volumes

- `/src` python libraries installed in edit mode, typically mounted from outside directory
  - Expect `/src/datacube-core` and `/src/odc-tools` to be present
- `/nb` notebooks, typically mounted from outside directory
- `/env` python environment is installed there on first run (typically docker volume)
- `$HOME` home folder is a volume (typically docker volume)
- `/run/postgresql` used to access postgresql db running on the host from within docker container via Unix socket

#### Ports

Port `9988` is exposed to allow connection to jupyter notebook/lab, can be configured at build time.

#### Entry Point Process

Entry point behaviour is defined in `with_bootstrap` bash script. It does the following:

- Setup some environment variables (`GDAL_DATA` for example)
- Build python environment if not present
- Activate python environment
- Possibly generate datacube configuration file from environment variables (see `dc_config_render.py`)
  - Compatible with current `datacube-core` docker environment variables `DB_HOSTNAME,DB_USERNAME,...`
  - Supports new style `DATACUBE_DB_URL="postgresql://user:password@host:port/database"`
  - Will write to file pointed by `DATACUBE_CONFIG_PATH` or to `~/.datacube.conf`
  - Will not overwrite existing file
- Generate `~/.datacube_integration.conf` (if doesn't exist already), for running integration tests
- Run one of the named commands `lab,notebook,rebuild-env,check-code,help` or run arbitrary program available within the docker image


### Python Environment

Following files in `./conf/` directory fully define python environment, they can be customized by the developer to include more dependencies, or add more libraries in edit mode.


| Files                        | Description                                                     |
| ----------------------------:|-----------------------------------------------------------------|
| `requirements.txt`           | Base dependencies, get compiled into wheels during docker build |
| `requirements-odc.txt`       | ODC dependencies installed in edit mode                         |
| `lab-extensions.txt`         | Jupyter lab extensions to install                               |
| `lab-server-extensions.txt`  | Jupyter server extensions to enable                             |

Python environment build process is in several stages.

1. `requirements.txt` is used during docker build to download and build all the python packages. Pre-built packages are stored in `/wheels` directory of the docker image. Some of those wheels will be already present in the base image `opendatacube/geobase:wheels`.
2. On the first run python environment will be bootstrapped from those wheels
3. More packages will be installed from `requirements-odc.txt`, these are mostly installed in edit mode
4. Any jupyter lab extensions will be installed and compiled next
5. Any jupyter lab extensions that have server component will be enabled


### Access to database

One can configure datacube to access whatever external database via usual mechanism (i.e. `~/.datacube.conf`). But since we want to run integration tests it's best to connect to a local db for which you have write permissions. This is done via docker volumes, see `./run.sh`. You should have a working DB install on your host dev machine:

```
# install database server and client
sudo apt install postgresql-10 postgresql-client-10

# add yourself as admin db user
sudo -u postgres createuser --superuser $USER

# create default db for your user
createdb "$USER"

# create `datacube` database
createdb datacube

# create database for integration tests
createdb agdcintegration
```

Since user within the docker container has the same UID as your user on the host, you will have the same database permissions when running from inside the docker container. And since we are using Unix sockets rather than TCP we don't need to worry about setting up passwords.
