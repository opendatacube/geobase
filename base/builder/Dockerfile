FROM buildpack-deps:bionic

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install Tini
# tini is useful inside runners, it's easier to copy it from builder than download (which requires curl or wget)
RUN curl -s -L -O https://github.com/krallin/tini/releases/download/v0.18.0/tini \
  && echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - \
  && install -m 755 tini /bin/tini \
  && rm tini

# Install newer node the nodejs package includes npm. This runs apt-get update, but doesn't install
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y --fix-missing --no-install-recommends \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# get a more recent cmake than what's in Ubuntu
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh \
  -q -O /tmp/cmake-install.sh \
  && chmod u+x /tmp/cmake-install.sh \
  && /tmp/cmake-install.sh --skip-license --prefix=/usr/local/ \
  && rm /tmp/cmake-install.sh

# Install common base python things
RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
    # upgrade linux-libc-dev to address CVEs
    linux-libc-dev \
    python3-dev python3-pip python3-venv \
    fakeroot checkinstall \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip \
  && hash -r \
  && pip3 install --no-cache-dir \
     setuptools wheel cython numpy


RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
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

COPY ./builder.sh /usr/local/bin/

RUN mkdir -p /dl
COPY ./build_openjpeg.sh /usr/local/bin/

COPY ./build_proj.sh /usr/local/bin/
ARG V_PROJ=6.3.0
RUN builder.sh proj-${V_PROJ} /dl :download:
RUN echo "Building proj 6" \
  && builder.sh proj-${V_PROJ} /dl/ /tmp/build \
  && dpkg -i /tmp/build/libproj_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

ARG V_GEOS=3.7.2
COPY ./build_geos.sh /usr/local/bin/
RUN builder.sh geos-${V_GEOS} /dl :download:
RUN echo "Building geos" \
  && builder.sh geos-${V_GEOS} /dl /tmp/build \
  && dpkg -i /tmp/build/libgeos_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

ARG V_KEA=1.4.12
COPY ./build_kea.sh /usr/local/bin/
RUN builder.sh kea-${V_KEA} /dl :download:
RUN echo "Building KEA" \
  && builder.sh kea-${V_KEA} /dl /tmp/build \
  && dpkg -i /tmp/build/libkea_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

COPY ./build_gdal.sh /usr/local/bin/
COPY ./gdal.opts /opt/
ARG V_GDAL=3.0.4
RUN builder.sh gdal-${V_GDAL} /dl :download:
RUN echo "Building gdal" \
  && FEATURES="$(cat /opt/gdal.opts)" builder.sh gdal-${V_GDAL} /dl /tmp/build /usr \
  && dpkg -i /tmp/build/libgdal_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build
