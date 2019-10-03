#!/bin/bash

set -eu
nb_dir="${1:-$(pwd)}"
nb_port="${2:-9988}"

docker run \
       -v ${nb_dir}:/nb \
       -p ${nb_port}:9988 \
       -ti --rm \
       geobase:local $@
