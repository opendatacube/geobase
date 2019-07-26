#!/bin/bash

set -eu

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cd "${SDIR}"
docker build \
       --tag kkodc/geo-builder ./base

docker build \
       --build-arg USER_NAME=$USER \
       --build-arg UID=$UID \
       --tag geo-builder:local ./local
