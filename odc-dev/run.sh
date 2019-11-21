#!/bin/bash

# settings
#  src_dir is where you `datacube-core` and `odc-tools` are checked out
#    git clone git@github.com:opendatacube/datacube-core.git
#    git clone git@github.com:opendatacube/odc-tools.git
#
#  nb_dir is for notebooks
#
src_dir="${HOME}/wk"
nb_dir="${HOME}/NB"
nb_port="9988"
env_volume="odc-dev.${USER}.env"
home_volume="odc-dev.${USER}.home"
image_name="odc-dev"

for volume in ${home_volume} ${env_volume}; do
    docker volume inspect "${volume}" 2> /dev/null > /dev/null || {
        echo "Creating volume: ${volume}"
        docker volume create "${volume}"
    }
done

exec docker run \
       -ti --rm \
       --hostname "odc-dev-dkr" \
       -v ${nb_dir}:"/nb" \
       -v ${src_dir}:"/src" \
       -v ${env_volume}:"/env" \
       -v ${home_volume}:"/home/${USER}" \
       -v /run/postgresql:/run/postgresql \
       -p ${nb_port}:${nb_port} \
       "${image_name}" $@
