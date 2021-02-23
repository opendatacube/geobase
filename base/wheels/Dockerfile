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

COPY ./constraints.txt constraints.txt

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  netcdf4 \
  && rm -rf ~/.cache/pip

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=h5py  \
  --no-deps \
  -c /wheels/constraints.txt \
  h5py \
  && rm -rf ~/.cache/pip

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  tables \
  && rm -rf ~/.cache/pip

RUN CFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
  pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  cartopy

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  fiona

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  shapely

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  pyproj

RUN pip3 wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /wheels/constraints.txt \
  rasterio

RUN rm constraints.txt

COPY env-build-tool /usr/local/bin/
