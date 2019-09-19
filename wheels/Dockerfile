FROM kkodc/geobase:builder as builder

RUN mkdir -p /wheels
WORKDIR /wheels

# numpy and cython are often needed
RUN pip wheel --no-cache-dir \
  --no-binary=:all: \
  numpy \
  Cython

RUN pip install numpy-*whl
RUN pip install Cython-*whl

RUN echo "GDAL==$(gdal-config --version)" > /tmp/constraints.txt \
  && PROJ_DIR=/opt/proj6 pip wheel --no-cache-dir \
  --no-binary=:all: \
  --no-deps \
  -c /tmp/constraints.txt \
  GDAL \
  rasterio \
  fiona \
  shapely \
  pyproj \
  && rm /tmp/constraints.txt

RUN PATH=/opt/proj6/bin:$PATH \
  CFLAGS="-I/opt/proj6/include -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
  LDFLAGS=-L/opt/proj6/lib \
  pip wheel --no-cache-dir \
  --no-binary=:all: \
  --no-deps \
  cartopy

RUN pip wheel --no-cache-dir \
  --no-binary=:all:  \
  --no-deps \
  h5py \
  netcdf4 \
  pyyaml \
  ruamel.yaml \
  pyrsistent \
  ciso8601 \
  psycopg2
