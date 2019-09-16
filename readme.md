kkodc/geo-builder
=================

Docker to build recent versions of geospatial libraries

- PROJ 5.2.0 and 6.1.1
- GEOS 3.7.2
- GDAL 2.4.2

Folder structure:

- `base/{Dockerfile,builder.sh}` base image: `docker pull kkodc/geo-builder`
  - `/dl/` contains downloaded sources
  - `/opt/` contains built `.deb` for geos/gdal
  - `/opt/proj5` contains static proj5
  - `/opt/proj6` contains static proj6
- `local/Dockerfile` build this locally with your `USER` and `UID`

Typical work flow:

- Build local builder image that will write files with your username to supplied volume

```
docker build \
       --build-arg USER_NAME=$USER \
       --build-arg UID=$UID \
       --tag geo-builder:local ./local
```

- Run shell inside it

```
mkdir -p build dl

docker run \
       -v $(pwd)/dl:/dl \
       -v $(pwd)/build:/build \
       -ti --rm \
       geo-builder:local
```

Once inside you can build python wheels, for example:

```
pip3 wheel --no-deps --no-binary :all: \
     GDAL==$(gdal-config --version) \
     pyproj \
     Shapely \
     fiona \
     rasterio \
     h5py
```
