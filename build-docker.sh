#!/bin/bash

set -eu

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cd "${SDIR}"
exec docker build \
     --build-arg USER_NAME=$USER \
     --build-arg UID=$UID \
     --tag kkodc/geo-builder .
