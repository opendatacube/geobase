#!/bin/bash

image_name="odc-dev"
nb_port=9988

docker build \
       --build-arg nb_user=$USER \
       --build-arg nb_uid=$(id -u $USER) \
       --build-arg nb_port="${nb_port}" \
       --tag "${image_name}" \
       .
