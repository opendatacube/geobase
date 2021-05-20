FROM buildpack-deps:focal

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
    libzstd-dev \
    libtiff5-dev \
    libpng-dev \
    libgif-dev \
    libdeflate-dev \
    libnetcdf-dev \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libopenjp2-7-dev \
    libkml-dev \
    libatlas-base-dev \
    gfortran \
    libspatialindex-dev \
    libsfcgal-dev \
    libudunits2-dev \
    libgeos-dev \
    libgeos++-dev \
    pybind11-dev \
    libeigen3-dev \
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

COPY ./build_lerc.sh /usr/local/bin/
ARG V_LERC=2.2.1
RUN builder.sh lerc-${V_LERC} /dl :download:
RUN echo "Building LERC" \
    && builder.sh lerc-${V_LERC} /dl /tmp/build \
    && dpkg -i /tmp/build/liblerc_*deb \
    && mv /tmp/build/*deb /opt/ \
    && rm -rf /tmp/build

COPY ./build_kea.sh /usr/local/bin/
ARG V_KEA=1.4.14
RUN builder.sh kea-${V_KEA} /dl :download:
RUN echo "Building KEA" \
  && builder.sh kea-${V_KEA} /dl /tmp/build \
  && dpkg -i /tmp/build/libkea_*deb \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

COPY ./build_proj.sh /usr/local/bin/
ARG V_PROJ=7.2.1
RUN builder.sh proj-${V_PROJ} /dl :download:
RUN echo "Building PROJ" \
  && builder.sh proj-${V_PROJ} /dl /tmp/build \
  && dpkg -i /tmp/build/libproj_*deb \
  && ldconfig \
  && mv /tmp/build/*deb /opt/ \
  && rm -rf /tmp/build

COPY ./build_gdal.sh /usr/local/bin/
ARG V_GDAL=3.3.0
RUN builder.sh gdal-${V_GDAL} /dl :download:
COPY ./gdal.opts /opt/
RUN echo "Building gdal" \
  && FEATURES="$(cat /opt/gdal.opts)" builder.sh gdal-${V_GDAL} /dl /tmp/build /usr/local \
  && dpkg -i /tmp/build/libgdal_*deb \
  && mv /tmp/build/*deb /opt/ \
  && ldconfig \
  && rm -rf /tmp/build

RUN groupadd --gid 1000 odc \
    && useradd --gid 1000 \
    --uid 1000 \
    --create-home \
    --shell /bin/bash -N odc \
    && adduser odc users \
    && adduser odc sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && true

VOLUME ["/wk"]
WORKDIR /wk
COPY assets/with_bootstrap /usr/local/bin/
ENTRYPOINT ["/bin/tini", "-s", "--", "/usr/local/bin/with_bootstrap"]


# Python env building utilities
COPY assets/requirements-base.txt /conf/requirements-base.txt
RUN mkdir -p /wk \
    && python3 -m pip install -U pip setuptools wheel \
    && python3 -m pip install -r /conf/requirements-base.txt \
    && rm -rf /root/.cache

COPY assets/nobinary-geo.txt /conf/nobinary-geo.txt
COPY assets/env-build-tool /usr/local/bin/env-build-tool
COPY assets/compile-wheels.mk /opt/
RUN echo "GDAL==$(gdal-config --version)" > /opt/constraints-gdal.txt \
    && mkdir -p /wk \

