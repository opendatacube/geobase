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
  scikit-learn \
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

# for jupyter lab builds we need npm
RUN apt-get update \
  && apt-get install -y \
  libssl1.0-dev nodejs-dev \
  && apt-get install -y libssl-dev \
  && apt-get install -y \
  npm \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Install Tini
# tini is useful inside runners, it's easier to copy it from builder than download (which requires curl or wget)
RUN curl -s -L -O https://github.com/krallin/tini/releases/download/v0.18.0/tini \
  && echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - \
  && install -m 755 tini /bin/tini \
  && rm tini

