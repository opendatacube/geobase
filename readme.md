kkodc/geobase
=============

[![Actions Status](https://github.com/Kirill888/geobase/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/Kirill888/geobase/actions)


Set of docker images to build recent versions of geospatial libraries and python environments that use them.

- PROJ 6.2.0
- GEOS 3.7.2
- GDAL 3.0.2

Overview
========

Basic idea is to use multi-stage builds to minimize output docker image size and to reduce surface area for security/deployment concerns.

Each step is described in more detail below. Overall structure is as following

1. Build C/C++ libs for PROJ,GEOS,GDAL in `base/builder`, package GEOS and GDAL in `.deb`
2. Download and build python wheels against compiled GDAL/GEOS/PROJ in `base/wheels`
3. Include run-time libs needed by libs/wheels built in stages 1 and 2 in `base/runner`
4. Use multi-stage building technique to construct docker image with customized python environment that suits your needs:
   - Base `builder` stage on `kkodc/geobase:wheels`
   - Install any extra missing dev libs you need via `apt-get`
   - Construct python environment taking care to use pre-compiled wheels where possible
   - Base runner stage on `kkodc/geobase:runner`
   - Install any extra C/C++ run time libs via `apt-get`
   - Copy the entire python environment across from `builder` stage


## base/builder

- Based on `buildack-deps:bionic`
- Builds PROJ, GEOS and GDAL from source
- Contains lots of dev libs to enable compilation of common python modules that call out to C/C++
- least changing layer


Folder structure:

- `base/builder/Dockerfile` base builder image: `docker pull kkodc/geobase:builder`
  - `/dl/` contains downloaded sources
  - `/opt/` contains built `.deb` for geos/gdal/proj6
- `base/builder/gdal.opts` feature selection for compiled GDAL, removing features should be easy, adding might require installing extra build dependencies with `apt-get`, might also need to add those extra libs to `base/runner/Dockerfile`.


## base/wheels

Next layer up from `builder`. Downloads and builds a collection of geospatial/numeric and related python wheels:

- GEO: GDAL, shapely, pyproj, rasterio, fiona, cartopy
- Numeric: scipy, pandas, scikit-image, numexpr, matplotlib
- IO: h5py, netcdf4, pyzmq, tornado, aiohttp
- MISC, covers categories like: yaml, time, db, serialization, jupyter related libs

This layer is used a `builder` base in the multi-stage build.


## base/runner

Derives from `ubuntu:18.04`, has all the necessary C/C++/Fortran libs installed in non-dev mode to run python wheels from `base/wheels`.

It is used as base for "runner dockers" that use multi-stage building technique: builder stage constructs a python environment using pre-compiled wheels + whatever extra downloaded from pypi.


## local/Dockerfile

Mostly used as a development aid, useful for investigating compilation issues for new libs one would want to add.

- `local/Dockerfile` build this locally with your `USER` and `UID`
- It's basically just `kkodc/geobose:wheels` that runs by default with your user id and ads some data volumes

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
