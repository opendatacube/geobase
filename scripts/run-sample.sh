#!/bin/bash

set -eu
nb_dir="${1:-$(pwd)/nb}"
nb_port="${2:-9988}"

[ -d ${nb_dir} ] || {
    echo "Creating ${nb_dir}"
    mkdir -p "${nb_dir}"
}

echo "Launching: ${nb_dir} ${nb_port}"

docker run \
       -ti --rm \
       -v ${nb_dir}:"/home/${USER}" \
       -v /run/postgresql:/run/postgresql \
       -e DATACUBE_CONFIG_PATH="/conf/datacube.conf" \
       -e DB_DATABASE=datacube \
       -p ${nb_port}:9988 \
       geobase:local_sample
