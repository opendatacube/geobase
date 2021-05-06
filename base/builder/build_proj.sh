#!/bin/bash


build_proj_shared () {
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
              -DLIBDIR="${prefix}/lib" \
              -DBUILD_TESTING=OFF \
              -DENABLE_IPO=YES \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
              -DCMAKE_INSTALL_PREFIX="${prefix}" \
     && make -j"${ncpus}" \
     && fakeroot checkinstall -y -D \
                 --pkgversion="${v}" \
                 --pkgname=libproj \
                 --backup=no \
                 --nodoc \
                 --fstrans=yes \
                 --install=no \
                 --pakdir="${rundir}" \
                 --maintainer=ODC \
                 make install \
    )
}


build_proj_static () {
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
                  -DLIBDIR="${prefix}/lib" \
                  -DBUILD_TESTING=OFF \
                  -DBUILD_LIBPROJ_SHARED=OFF \
                  -DENABLE_IPO=YES \
                  -DCMAKE_BUILD_TYPE=Release \
                  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                  -DCMAKE_INSTALL_PREFIX="${prefix}" \
         && make -j"${ncpus}" \
         && make install \
    )
}


if [ "${STATIC:-no}" == "yes" ]; then
   build_proj_static $@
else
   build_proj_shared $@
fi
