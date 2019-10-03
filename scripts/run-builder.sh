#!/bin/bash

set -eu

mkdir -p run
cd run
mkdir -p build dl envs

docker run \
       -v $(pwd)/dl:/dl \
       -v $(pwd)/build:/build \
       -v $(pwd)/envs:/envs \
       -ti --rm \
       geobase:local $@
