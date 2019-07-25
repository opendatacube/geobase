FROM buildpack-deps:bionic

ENV LC_ALL C.UTF-8

RUN apt-get update -y && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       python3-dev python3-pip

RUN pip3 install --no-cache --upgrade pip && hash -r && \
    pip3 install --no-cache setuptools wheel

RUN pip3 install numpy

RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
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
    libkml-dev

#libgeos-dev \

# dev conveniences
RUN apt-get update -y \
    && apt-get install -y --fix-missing --no-install-recommends \
    cmake-curses-gui \
    sudo \
    less

VOLUME ["/src"]
VOLUME ["/dl"]

ARG USER_NAME=ubuntu
ARG UID=1000

RUN adduser --disabled-password --gecos '' -u ${UID} ${USER_NAME}
RUN adduser ${USER_NAME} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /src

COPY ./builder.sh /usr/local/bin/

CMD ["/bin/bash"]
