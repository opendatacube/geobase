#!/bin/bash

set -eu

build_kea () {
    local src="${1%/}"
    local v="${2}"
    local prefix="${3:-/usr}"
    local b="${4:-${src}-build}"
    local src_absolute=$(readlink -f "${src}")
    local rundir=$(pwd)
    local ncpus=$(awk '/^processor/{print $3}' /proc/cpuinfo | wc -l)

    [ -d "${b}" ] || mkdir -p "${b}"
    (cd "${b}" \
         && cmake "${src_absolute}" \
                  -DCMAKE_BUILD_TYPE=Release \
                  -DLIBKEA_WITH_GDAL=OFF \
                  -DBUILD_SHARED_LIBS=ON \
                  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                  -DCMAKE_INSTALL_PREFIX="${prefix}" \
         && make -j"${ncpus}" \
         && fakeroot checkinstall -y -D \
                     --pkgversion=${v} \
                     --pkgname=libkea \
                     --backup=no \
                     --nodoc \
                     --fstrans=yes \
                     --install=no \
                     --pakdir="${rundir}" \
                     --maintainer=ODC \
                     make install \
        )
}

build_kea $@
