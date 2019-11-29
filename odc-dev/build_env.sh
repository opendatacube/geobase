#!/bin/bash

set -eu
set -x

env_dir="${PYENV:-/env}"
pip="${env_dir}/bin/pip"
jupyter="${env_dir}/bin/jupyter"
cc="/conf"
python3 -m venv "${env_dir}"

$pip install -U pip setuptools

$pip install \
    --find-links=/wheels/ \
    --no-cache-dir \
    --no-index \
    -c "${cc}/bins.txt" \
    -r "${cc}/requirements.txt"

$pip install \
    --find-links=/wheels/ \
    --no-cache-dir \
    -c "${cc}/bins.txt" \
    -r "${cc}/requirements-odc.txt"

while read line; do
    $jupyter labextension install --no-build $line
done < "${cc}/lab-extensions.txt"
$jupyter lab build

while read line; do
    $jupyter serverextension enable --py $line
done < "${cc}/lab-server-extensions.txt"
