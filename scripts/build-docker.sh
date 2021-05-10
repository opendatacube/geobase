#!/bin/bash

set -eu

docker build --tag "opendatacube/geobase-builder:latest" ./base/builder
docker build --tag "opendatacube/geobase-runner:latest" ./base/runner
