#!/bin/bash

# settings
nb_dir="${HOME}/NB}"
src_dir="${HOME}/wk"
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

#cmd="jupyter lab --ip=0.0.0.0 --port=${nb_port} --no-browser"
exec docker run \
       -ti --rm \
       -v ${nb_dir}:"/nb" \
       -v ${src_dir}:"/src" \
       -v ${env_volume}:"/env" \
       -v ${home_volume}:"/home/${USER}" \
       -v /run/postgresql:/run/postgresql \
       -p ${nb_port}:${nb_port} \
       "${image_name}" $@
