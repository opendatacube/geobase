FROM buildpack-deps:bionic

ENV LC_ALL C.UTF-8

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
   python3-dev python3-pip python3-venv \
   fakeroot checkinstall \
&& rm -rf /var/lib/apt/lists/*

# get a more recent cmake than what's in Ubuntu
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh \
  -q -O /tmp/cmake-install.sh \
  && chmod u+x /tmp/cmake-install.sh \
  && /tmp/cmake-install.sh --skip-license --prefix=/usr/local/ \
  && rm /tmp/cmake-install.sh

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    sqlite3 \
    libjpeg-dev \
    libexpat-dev \
    libxerces-c-dev \
    libwebp-dev \
    libzstd1-dev \
    libnetcdf-dev \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libopenjp2-7-dev \
    libkml-dev \
    libatlas-base-dev \
    gfortran \
    libspatialindex-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# dev conveniences
RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
    htop \
    tmux \
    sudo \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache --upgrade pip \
  && hash -r \
  && pip3 install --no-cache setuptools wheel cython

COPY ./builder.sh /usr/local/bin/

RUN echo "Downloading libs" \
  && mkdir -p /dl \
  && builder.sh proj-6.2.0 /dl :download: \
  && builder.sh geos-3.7.2 /dl :download: \
  && builder.sh gdal-3.0.2 /dl :download: \
  && echo "done"

COPY ./build_openjpeg.sh /usr/local/bin/

COPY ./build_proj.sh /usr/local/bin/
RUN echo "Building proj 6" \
  && builder.sh proj-6.2.0 /dl/ /tmp/build \
  && dpkg -i /tmp/build/libproj_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

COPY ./build_geos.sh /usr/local/bin/
RUN echo "Building geos" \
  && builder.sh geos /dl /tmp/build \
  && dpkg -i /tmp/build/libgeos_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

COPY ./build_gdal.sh /usr/local/bin/
COPY ./gdal.opts /opt/
RUN echo "Building gdal" \
&& FEATURES="$(cat /opt/gdal.opts)" builder.sh gdal-3.0.2 /dl /tmp/build /usr \
&& dpkg -i /tmp/build/libgdal_*deb \
&& mv /tmp/build/*deb /opt/ \
&& rm -rf /tmp/build
