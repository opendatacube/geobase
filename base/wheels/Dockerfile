ARG base=opendatacube/geobase:builder
FROM ${base}

RUN mkdir -p /wheels
WORKDIR /wheels

RUN echo "GDAL==$(gdal-config --version)" > /tmp/constraints.txt \
  && pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /tmp/constraints.txt \
  GDAL \
  && rm /tmp/constraints.txt

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  pyproj

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  rasterio \
  fiona \
  shapely

RUN CFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
  pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  cartopy

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  netcdf4 \
  && rm -rf ~/.cache/pip

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  h5py \
  && rm -rf ~/.cache/pip

COPY env-build-tool /usr/local/bin/
