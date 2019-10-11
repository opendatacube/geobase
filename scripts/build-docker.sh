#!/bin/bash

set -eu

[ "${1-:}" == "base" ] && {
    # by default pull builder/wheels from docker hub
    docker build --tag "kkodc/geobase:builder" ./base/builder
    docker build --tag "kkodc/geobase:wheels" ./base/wheels
    docker build --tag "kkodc/geobase:runner" ./base/runner
}

[ "${1-:}" == "sample" ] && {
    docker build \
           --build-arg nb_user=$USER \
           --build-arg nb_uid=$(id -u $USER) \
           --tag "geobase:local_sample" ./sample
    exit 0
}

docker build \
       --build-arg USER_NAME=$USER \
       --build-arg UID=$(id -u $USER) \
       --tag geobase:local ./local
