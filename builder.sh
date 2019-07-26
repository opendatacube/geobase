#!/bin/bash

set -euo pipefail

versions='
openjpeg 2.3.1 https://github.com/uclouvain/openjpeg/archive/v{{version}}.tar.gz
geos     3.7.2 https://github.com/libgeos/geos/archive/{{version}}.tar.gz
proj     6.1.1 https://github.com/OSGeo/proj/releases/download/{{version}}/proj-{{version}}.tar.gz
gdal     2.4.2 https://download.osgeo.org/gdal/{{version}}/gdal-{{version}}.tar.gz
'

ncpus=$(awk '/^processor/{print $3}' /proc/cpuinfo | wc -l)

get_version () {
    local lib="${1}"
    echo "${versions}" | awk "/^${lib} /"'{print $2}'
}

get_url () {
    local lib="${1}"
    local v=${2:-$(get_version "${lib}")}
    local uu=$(echo "${versions}" | awk "/^${lib} /"'{print $3}')
    echo $uu | sed "s/{{version}}/${v}/g"
}

all_libs () {
    echo "${versions}" | awk "/^[a-z]/"'{print $1}'
}

download () {
    local lib="${1}"
    local v=${2:-$(get_version "${lib}")}
    local dl="${3}"
    local u=$(get_url "${lib}" "${v}")
    local dst="${dl}/${lib}-${v}.tar.gz"

    if [ ! -f "${dst}" ] ; then
        echo "Fetching $lib $v"
        echo "  $dst <= $u"

        wget -O "${dst}" "${u}"
    fi
}

unpack () {
    local lib="${1}"
    local v=${2:-$(get_version "${lib}")}
    local dl="${3}"
    local src="${dl}/${lib}-${v}.tar.gz"
    local dst="${4:-.}/${lib}-${v}"

    if [ ! -d "${dst}" ] ; then
        echo "Unpacking: $src -> $dst"
        mkdir -p "${dst}"
        tar xz --strip-components=1 -C "${dst}" < "${src}"
    fi
}

build_geos () {
    local src="${1%/}"
    local v="${2}"
    local prefix="${3:-/usr}"
    local b="${4:-${src}-build}"
    local src_absolute=$(readlink -f "${src}")
    local rundir=$(pwd)

    [ -d "${b}" ] || mkdir -p "${b}"
    (cd "${b}" \
     && cmake "${src_absolute}" \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
              -DCMAKE_INSTALL_PREFIX="${prefix}" \
     && make -j"${ncpus}" \
     && fakeroot checkinstall -y -D \
                 --pkgversion=${v} \
                 --pkgname=libgeos \
                 --backup=no \
                 --nodoc \
                 --fstrans=yes \
                 --install=no \
                 --pakdir="${rundir}" \
                 --maintainer=ODC \
                 make install \
    )
}

build_proj () {
    local src="${1%/}"
    local v="${2}"
    local prefix="${3:-/usr}"
    local b="${4:-${src}-build}"
    local src_absolute=$(readlink -f "${src}")
    local rundir=$(pwd)

    [ -d "${b}" ] || mkdir -p "${b}"
    (cd "${b}" \
     && cmake "${src_absolute}" \
              -DENABLE_LTO=YES \
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

build_openjpeg () {
    local src="${1%/}"
    local v="${2}"
    local prefix="${3:-/usr}"
    local b="${4:-${src}-build}"
    local src_absolute=$(readlink -f "${src}")
    local rundir=$(pwd)

    [ -d "${b}" ] || mkdir -p "${b}"
    (cd "${b}" \
        && cmake "${src_absolute}" \
                 -DCMAKE_BUILD_TYPE=Release \
                 -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                 -DCMAKE_INSTALL_PREFIX="${prefix}" \
        && make -j"${ncpus}" \
        && fakeroot checkinstall -y -D \
                    --pkgversion="${v}" \
                    --pkgname=libopenjp2 \
                    --backup=no \
                    --nodoc \
                    --fstrans=yes \
                    --install=no \
                    --pakdir="${rundir}" \
                    --maintainer=ODC \
                    make install \
    )
}

gdal_configure_libs () {
    local enabled_libs="$@"
    local gdal_features="armadillo bsb cfitsio charls crypto cryptopp curl dds ecw epsilon expat fgdb fme freexl\
 geos geotiff gif gnm grass grib gta hdf4 hdf5 hdfs idb ingres jasper java jp2lura jp2mrsid jpeg jpeg12 kakadu\
 kea lerc libgrass libjson-c libkml liblzma libtiff libtool libz mdb mongocxx mrf mrsid mrsid-lidar msg mysql\
 netcdf null oci odbc ogdi opencl openjpeg pam pcidsk pcraster pcre pdfium perl pg png podofo poppler python qhull\
 rasdaman rasterlite2 sde sfcgal sosi spatialite sqlite3 teigha teigha-plt threads webp xerces xml2 zstd"

    for f in $@ ; do
        echo "--with-${f}"
    done

    for f in $gdal_features ; do
        [ -z "${enabled_libs##*$f*}" ] || {
            echo "--without-$f"
        }
    done
}

build_gdal () {
    local src="${1%/}"
    local v="${2}"
    local prefix="${3:-/usr}"
    local src_absolute=$(readlink -f "${src}")
    local rundir=$(pwd)

    local libs="
geos
proj
curl
crypto
libtiff=internal
geotiff=internal
jpeg=internal
qhull=internal
png=internal
jpeg12
openjpeg
webp
gif=internal
lerc
netcdf hdf4 hdf5
zstd
libz=internal
liblzma
libkml
pam
libjson-c
sqlite3
pg
xerces
xml2
expat
pcre
threads
"
    (cd "${src}" \
         && ./configure \
                --prefix="${prefix}" \
                --enable-lto \
                --with-hide-internal-symbols \
                --with-rename-internal-libtiff-symbols \
                --with-rename-internal-libgeotiff-symbols \
                $(gdal_configure_libs ${libs}) \
         && make -j${ncpus} \
         && strip ./libgdal.so \
         && fakeroot checkinstall -y -D \
                     --pkgversion="${v}" \
                     --pkgname=libgdal \
                     --backup=no \
                     --nodoc \
                     --fstrans=yes \
                     --install=no \
                     --pakdir="${rundir}" \
                     --maintainer=ODC \
                     make install \
        )
}

build_lib () {
    local lib=$(echo "${1}" | awk -F - '{print $1}')
    local v=$(echo "${1}" | awk -F - '{print $2}')
    local dl="${2:-/dl}"
    local bdir="${3:-./}"
    local prefix="${4:-/usr}"

    v=${v:=$(get_version $lib)}

    [ -d "${dl}" ] || mkdir -p "${dl}"
    [ -d "${bdir}" ] || mkdir -p "${bdir}"
    echo "Buidling: ${lib}::<${v}>   paths: dl:$dl build:$bdir prefix:$prefix"

    download "${lib}" "${v}" "${dl}"
    unpack "${lib}" "${v}" "${dl}" "${bdir}"
    (cd "${bdir}" \
         && "build_${lib}" "${lib}-${v}" "${v}" "${prefix}")
}

if [ $# -eq 0 ]; then
    echo 'Usage:'
    echo '   builder.sh ${lib} [dowdload_dir=/dl build_dir=./ prefix=/usr]'
    echo '   builder.sh ${lib}-${version} [dowdload_dir=/dl build_dir=./ prefix=/usr]'
    echo ''
    echo 'Where ${lib} is one of geos|proj|openjpeg|gdal'
else
   build_lib $@
fi

