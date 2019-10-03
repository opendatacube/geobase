#!/bin/bash

set -eu

[ "${1-:}" == "base" ] && {
    # by default pull builder/wheels from docker hub
    docker build --tag "kkodc/geobase:builder" ./base/builder
    docker build --tag "kkodc/geobase:wheels" ./base/wheels
    docker build --tag "kkodc/geobase:runner" ./base/runner
}

docker build \
       --build-arg USER_NAME=$USER \
       --build-arg UID=$UID \
       --tag geobase:local ./local
