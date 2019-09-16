#!/bin/bash

set -euo pipefail

versions='
openjpeg 2.3.1 https://github.com/uclouvain/openjpeg/archive/v{{version}}.tar.gz
geos     3.7.2 https://github.com/libgeos/geos/archive/{{version}}.tar.gz
proj     6.1.1 https://github.com/OSGeo/proj/releases/download/{{version}}/proj-{{version}}.tar.gz
gdal     2.4.2 https://download.osgeo.org/gdal/{{version}}/gdal-{{version}}.tar.gz
'


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



build_lib () {
    local lib=$(echo "${1}" | awk -F - '{print $1}')
    local v=$(echo "${1}" | awk -F - '{print $2}')
    local dl="${2:-/dl}"
    local bdir="${3:-./}"
    local prefix="${4:-/usr}"
    local build_script="build_${lib}.sh"

    v=${v:=$(get_version $lib)}

    [ -d "${dl}" ] || mkdir -p "${dl}"
    [ -d "${bdir}" ] || mkdir -p "${bdir}"
    echo "Building: ${lib}::<${v}>   paths: dl:$dl build:$bdir prefix:$prefix"

    download "${lib}" "${v}" "${dl}"

    if [ "$bdir" == ":download:" ]; then
        return 0
    fi

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
