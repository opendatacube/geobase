opendatacube/geobase
====================

[![Actions Status](https://github.com/opendatacube/geobase/workflows/build/badge.svg)](https://github.com/opendatacube/geobase/actions)
[![Builder Scan](https://github.com/opendatacube/geobase/workflows/Builder%20Scan/badge.svg)](https://github.com/opendatacube/geobase/actions)
[![Runner Scan](https://github.com/opendatacube/geobase/workflows/Runner%20Scan/badge.svg)](https://github.com/opendatacube/geobase/actions)


Set of docker images to build recent versions of geospatial libraries and python environments that use them.

- GEOS 3.8.0 (from apt)
- PROJ 7.2.1 (compiled)
- KEA 1.4.14 (compiled)
- LERC 2.2.1 (compiled)
- GDAL 3.3.0 (compiled)

Quick Start
===========

1. Create `requirements.txt` and `constraints.txt` (could be empty)

```
rasterio[s3]
pyproj
```

2. Create `Dockerfile`

```docker
FROM opendatacube/geobase-builder as env_builder
COPY requirements.txt /
COPY constraints.txt /
RUN env-build-tool new /requirements.txt /constraints.txt /env


FROM opendatacube/geobase-runner
COPY --from=env_builder /env /env
ENV LC_ALL=C.UTF-8
ENV PATH="/env/bin:${PATH}"
```

See [sample](sample/) directory for more information.

Overview
========

Basic idea is to use multi-stage builds to minimize output docker image size and to reduce surface area for security/deployment concerns.

Each step is described in more detail below. Overall structure is as following

1. Build C/C++ libs for PROJ,LERC,KEA,GDAL in `base/builder`, package those in `.deb`
3. Include run-time libs needed by libs built in stages 1 and 2 in `base/runner`
4. Use multi-stage building technique to construct docker image with customized python environment that suits your needs:
   - Base `builder` stage on `opendatacube/geobase-builder:${V_BASE}`
   - Install any extra missing dev libs you need via `apt-get`
   - Construct python environment taking care to use pre-compiled wheels where possible
   - Base runner stage on `opendatacube/geobase-runner:${V_BASE}`
   - Install any extra C/C++ run time libs via `apt-get`
   - Copy the entire python environment across from `builder` stage


## base/builder

- Based on `buildack-deps:focal` (Ubuntu 20.04)
- Builds LERC, KEA and GDAL from source
- Contains lots of dev libs to enable compilation of common python modules that call out to C/C++
- Least changing layer


Folder structure:

- `base/builder/Dockerfile` base builder image: `docker pull opendatacube/geobase-builder`
  - `/dl/` contains downloaded sources
  - `/opt/` contains built `.deb` for geos/gdal/proj6
- `base/builder/gdal.opts` feature selection for compiled GDAL, removing features should be easy, adding might require installing extra build dependencies with `apt-get`, might also need to add those extra libs to `base/runner/Dockerfile`.


## base/runner

Derives from `ubuntu:20.04`, has all the necessary C/C++/Fortran libs installed in non-dev mode to run python wheels compiled in `base/builder`.

It is used as base for "runner dockers" that use multi-stage building technique: builder stage constructs a python environment using pre-compiled wheels + whatever extra downloaded from pypi.


## Building Test Environment for your library

You need to supply 3 files

- `requirements.txt` contains top level requirements you need for testing your library (avoid pinning versions in there)
- `constraints.txt` often it's output of `pip freeze` from a known to work environment (also have a look at `pip-compile` tool)
- `nobinary.txt` can be empty, contains libraries you prefer to compile locally
  rather than using `manylinux` wheels from pypi. Note that common geospatial
  libraries will be compiled to ensure consistent C library usage across those
  packages regardless of the content of your `nobinary.txt` file. For a full
  list see `/conf/nobinary.txt` inside the docker.

Put all three files in one folder. Then you can run something like the script
below to generate wheels and build python environment from that. Wheels and
sources will be stored in `./wheels` directory, and python environment is
`./env`, there will also be `.cache/pip` directory.

```bash
#!/bin/bash

# points to your code on dev/test machine
# must be an absolute path, hence `readlink -f ...`
CODE=$(readlink -f "$HOME/src/your_lib")

dkr() {
  local img=${IMG:-"opendatacube/geobase-builder:latest"}
  docker run --rm -ti \
    -v "${CODE}":/code \
    -v $(pwd):/wk \
    -e NOBINARY=/wk/nobinary.txt \
    ${img} \
    $@
}

# Download wheels and sources
dkr env-build-tool download requirements.txt constraints.txt ./wheels

# Compile sources
dkr env-build-tool compile ./wheels

# Assemble environment
dkr env-build-tool new_no_index requirements.txt constraints.txt ./env ./wheels

# Install your code in edit mode
dkr /wk/env/bin/python -m pip install -e /code

# Verify tests can run
dkr /wk/env/bin/pytest /code
```
