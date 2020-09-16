#!/bin/bash

set -eu

GDAL_DEFAULT_FEATURES="
proj
geos
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
netcdf
hdf4
hdf5
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

gdal_configure_libs () {
    local enabled_libs=$@
    local gdal_features="armadillo cfitsio charls crypto cryptopp curl dds ecw epsilon expat fgdb fme freexl\
 geos geotiff gif gnm grass gta hdf4 hdf5 hdfs idb ingres jasper java jp2lura jp2mrsid jpeg jpeg12 kakadu\
 kea lerc libgrass libjson-c libkml liblzma libtiff libtool libz mdb mongocxx mrsid mrsid-lidar msg mysql\
 netcdf null oci odbc ogdi opencl openjpeg pam pcidsk pcraster pcre pdfium perl pg png podofo poppler python qhull\
 rasdaman rasterlite2 sde sfcgal sosi spatialite sqlite3 teigha teigha-plt threads webp xerces xml2 zstd"

    for f in $enabled_libs ; do
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
    local libs=${FEATURES:-$GDAL_DEFAULT_FEATURES}
    local ncpus=$(awk '/^processor/{print $3}' /proc/cpuinfo | wc -l)

    echo "${libs}"
    echo "----------------------------"
    echo "$(gdal_configure_libs ${libs})"
    echo "----------------------------"
    sleep 3

    (cd "${src}" \
         && ./configure \
                --prefix="${prefix}" \
                --enable-lto \
                --with-hide-internal-symbols \
                --with-rename-internal-libtiff-symbols \
                --with-rename-internal-libgeotiff-symbols \
                $(gdal_configure_libs ${libs}) \
         && sleep 3 \
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
                     --maintainer=xxx \
                     make install \
        )
}


build_gdal $@
