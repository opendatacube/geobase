FROM buildpack-deps:bionic

ENV LC_ALL C.UTF-8

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
   python3-dev python3-pip python3-venv \
   fakeroot checkinstall \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache --upgrade pip && hash -r && \
    pip3 install --no-cache setuptools wheel cython numpy

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    cmake \
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
    && rm -rf /var/lib/apt/lists/*

# dev conveniences
RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
    cmake-curses-gui \
    htop \
    tmux \
    sudo \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

COPY ./builder.sh /usr/local/bin/

RUN echo "Building base libs" \
    && builder.sh proj-5.2.0 /tmp/dl /tmp/build \
    && dpkg -i /tmp/build/libproj_*deb \
    && builder.sh geos /tmp/dl /tmp/build \
    && dpkg -i /tmp/build/libgeos_*deb \
    && builder.sh gdal /tmp/dl /tmp/build \
    && dpkg -i /tmp/build/libgdal_*deb \
    && mv /tmp/build/*deb /opt/ \
    && mv /tmp/dl/* /opt/ \
    && rm -rf /tmp/dl /tmp/build \
    && ls -lh /opt/*deb

