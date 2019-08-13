#!/bin/bash

set -eu

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
TAG="latest"

cd "${SDIR}"

[ "${1-:}" == "base" ] && {
    # by default pull base from docker hub
    docker build --tag "kkodc/geo-builder:${TAG}" ./base
}

docker build \
       --build-arg USER_NAME=$USER \
       --build-arg UID=$UID \
       --tag geo-builder:local ./local
