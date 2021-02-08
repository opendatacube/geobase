opendatacube/geobase
====================

[![Actions Status](https://github.com/opendatacube/geobase/workflows/build/badge.svg)](https://github.com/opendatacube/geobase/actions)
[![Builder Scan](https://github.com/opendatacube/geobase/workflows/Builder%20Scan/badge.svg)](https://github.com/opendatacube/geobase/actions)
[![Runner Scan](https://github.com/opendatacube/geobase/workflows/Runner%20Scan/badge.svg)](https://github.com/opendatacube/geobase/actions)
[![Wheels Scan](https://github.com/opendatacube/geobase/workflows/Wheels%20Scan/badge.svg)](https://github.com/opendatacube/geobase/actions)


Set of docker images to build recent versions of geospatial libraries and python environments that use them.

- PROJ 6.3.0
- GEOS 3.7.2
- GDAL 3.0.4

Quick Start
===========

1. Create `requirements.txt`

```
rasterio[s3]
pyproj
```

2. Create `Dockerfile`

```docker
FROM opendatacube/geobase:wheels as env_builder
COPY requirements.txt /
RUN env-build-tool new /requirements.txt /env /wheels


FROM opendatacube/geobase:runner
COPY --from=env_builder /env /env
ENV LC_ALL=C.UTF-8
ENV PATH="/env/bin:${PATH}"
```

See [sample](sample/) directory for more information.

Overview
========

Basic idea is to use multi-stage builds to minimize output docker image size and to reduce surface area for security/deployment concerns.

Each step is described in more detail below. Overall structure is as following

1. Build C/C++ libs for PROJ,GEOS,GDAL in `base/builder`, package those in `.deb`
2. Download and build python wheels against compiled GDAL/GEOS/PROJ in `base/wheels`
3. Include run-time libs needed by libs/wheels built in stages 1 and 2 in `base/runner`
4. Use multi-stage building technique to construct docker image with customized python environment that suits your needs:
   - Base `builder` stage on `opendatacube/geobase:wheels`
   - Install any extra missing dev libs you need via `apt-get`
   - Construct python environment taking care to use pre-compiled wheels where possible
   - Base runner stage on `opendatacube/geobase:runner`
   - Install any extra C/C++ run time libs via `apt-get`
   - Copy the entire python environment across from `builder` stage


## base/builder

- Based on `buildack-deps:bionic`
- Builds PROJ, GEOS and GDAL from source
- Contains lots of dev libs to enable compilation of common python modules that call out to C/C++
- least changing layer


Folder structure:

- `base/builder/Dockerfile` base builder image: `docker pull opendatacube/geobase:builder`
  - `/dl/` contains downloaded sources
  - `/opt/` contains built `.deb` for geos/gdal/proj6
- `base/builder/gdal.opts` feature selection for compiled GDAL, removing features should be easy, adding might require installing extra build dependencies with `apt-get`, might also need to add those extra libs to `base/runner/Dockerfile`.


## base/wheels

Next layer up from `builder`.

1. Common python config
2. Includes common binaries like `tini`
3. Some scripts for bootstrapping python environments easily

Downloads and builds a collection of geospatial/numeric and related python wheels:

- GEO: GDAL, shapely, pyproj, rasterio, fiona, cartopy
- IO: h5py, netcdf4

This layer is used as a `env_builder` base in the multi-stage build.


## base/runner

Derives from `ubuntu:18.04`, has all the necessary C/C++/Fortran libs installed in non-dev mode to run python wheels from `base/wheels`.

It is used as base for "runner dockers" that use multi-stage building technique: builder stage constructs a python environment using pre-compiled wheels + whatever extra downloaded from pypi.


## local/Dockerfile

Mostly used as a development aid, useful for investigating compilation issues for new libs one would want to add.

- `local/Dockerfile` build this locally with your `USER` and `UID`
- It's basically just `opendatacube/geobose:wheels` that runs by default with your user id and ads some data volumes

Typical work flow:

- Build local builder image that will write files with your username to supplied volume

```
./scripts/build-docker.sh
```

- Run shell inside it

```
mkdir -p run
cd run
mkdir -p build dl envs

docker run \
       -v $(pwd)/dl:/dl \
       -v $(pwd)/build:/build \
       -v $(pwd)/envs:/envs \
       -ti --rm \
       geobase:local
```

There is `./scripts/run-builder.sh` that does just that.

Once inside you can build python wheels or whole environments, for example:

```
pip3 wheel --no-deps --no-binary :all: \
     GDAL==$(gdal-config --version) \
     pyproj \
     Shapely \
     fiona \
     rasterio \
     h5py
```
