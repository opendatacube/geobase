#!/bin/bash

set -eu
nb_dir="${1:-$(pwd)}"
nb_port="${2:-9988}"

docker run \
       -ti --rm \
       -v ${nb_dir}:/nb \
       -v /run/postgresql:/run/postgresql \
       -e DB_DATABASE=datacube \
       -p ${nb_port}:9988 \
       geobase:local_sample $@
