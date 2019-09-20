FROM kkodc/geobase:builder as builder

RUN mkdir -p /wheels
WORKDIR /wheels

# numpy and cython are often needed
RUN pip wheel --no-cache-dir \
  --no-binary=:all: \
  numpy \
  Cython

RUN pip install \
  --no-cache-dir \
  --find-links . \
  --only-binary=numpy,cython \
  numpy cython

RUN echo "GDAL==$(gdal-config --version)" > /tmp/constraints.txt \
  && pip wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  -c /tmp/constraints.txt \
  GDAL \
  && rm /tmp/constraints.txt

RUN PROJ_DIR=/opt/proj6 pip wheel --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  pyproj

RUN pip wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  rasterio \
  fiona \
  shapely

RUN PATH=/opt/proj6/bin:$PATH \
  CFLAGS="-I/opt/proj6/include -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1" \
  LDFLAGS=-L/opt/proj6/lib \
  pip wheel \
  --no-cache-dir \
  --no-binary=:all: \
  --no-build-isolation \
  --no-deps \
  cartopy

RUN pip wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  h5py \
  netcdf4 \
  pyyaml \
  ruamel.yaml \
  ruamel.yaml.clib \
  pyrsistent \
  cffi \
  cftime \
  ciso8601 \
  psycopg2

RUN echo "Building scientific stack" \
&& pip wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  scipy \
  pandas \
  matplotlib \
  numexpr \
&& echo done

RUN echo "Building scientific stack: image processing" \
&& pip wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  Pillow \
  scikit-image \
&& echo done

RUN echo "Building jupyter related libs" \
&& pip wheel \
  --no-cache-dir \
  --no-binary=:all:  \
  --no-build-isolation \
  --no-deps \
  pyzmq \
  msgpack \
  tornado \
  yarl \
  multidict \
  aiohttp \
  MarkupSafe \
&& echo done
