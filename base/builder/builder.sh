#!/bin/bash

set -o errexit
set -o noclobber
set -o pipefail
set -o nounset

versions='
openjpeg  https://github.com/uclouvain/openjpeg/archive/v{{version}}.tar.gz
geos      https://github.com/libgeos/geos/archive/{{version}}.tar.gz
proj      https://github.com/OSGeo/proj/releases/download/{{version}}/proj-{{version}}.tar.gz
gdal      https://download.osgeo.org/gdal/{{version}}/gdal-{{version}}.tar.gz
kea       https://github.com/ubarsc/kealib/releases/download/kealib-{{version}}/kealib-{{version}}.tar.gz
'

get_url () {
    local lib="${1}"
    local v="${2}"
    local uu=$(echo "${versions}" | awk "/^${lib} /"'{print $2}')
    echo $uu | sed "s/{{version}}/${v}/g"
}

all_libs () {
    echo "${versions}" | awk "/^[a-z]/"'{print $1}'
}

download () {
    local lib="${1}"
    local v="${2}"
    local dl="${3}"
    local u=$(get_url "${lib}" "${v}")
    local dst="${dl}/${lib}-${v}.tar.gz"

    if [ ! -f "${dst}" ] ; then
        echo "Fetching $lib $v"
        echo "  $dst <= $u"

        wget --quiet -O "${dst}" "${u}"
    fi
}

unpack () {
    local lib="${1}"
    local v="${2}"
    local dl="${3}"
    local src="${dl}/${lib}-${v}.tar.gz"
    local dst="${4:-.}/${lib}-${v}"

    if [ ! -d "${dst}" ] ; then
        echo "Unpacking: $src -> $dst"
        mkdir -p "${dst}"
        tar xz --strip-components=1 -C "${dst}" < "${src}"
    fi
}



build_lib () {
    local lib=$(echo "${1}" | awk -F - '{print $1}')
    local v=$(echo "${1}" | awk -F - '{print $2}')
    local dl="${2:-/dl}"
    local bdir="${3:-./}"
    local prefix="${4:-/usr}"
    local build_script="build_${lib}.sh"

    [ -d "${dl}" ] || mkdir -p "${dl}"
    echo "Building: ${lib}::<${v}>   paths: dl:$dl build:$bdir prefix:$prefix"

    download "${lib}" "${v}" "${dl}"

    if [ "$bdir" == ":download:" ]; then
        return 0
    fi

    [ -d "${bdir}" ] || mkdir -p "${bdir}"
    unpack "${lib}" "${v}" "${dl}" "${bdir}"
    (cd "${bdir}" \
         && "${build_script}" "${lib}-${v}" "${v}" "${prefix}")
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
