#!/bin/bash

set -eu

IMG=${IMG:-opendatacube/geobase-builder:3.3.0}

mkdir -p run
cd run

docker run \
       -v $(pwd):/wk \
       -ti --rm \
       ${IMG} $@
