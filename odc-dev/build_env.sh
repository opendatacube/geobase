#!/bin/bash

set -eu
set -x

env_dir="${PYENV:-/env}"
pip="${env_dir}/bin/pip"
python3 -m venv "${env_dir}"

$pip install -U pip

$pip install \
    --find-links=/wheels/ \
    --no-cache-dir \
    --no-index \
    -c /wk/bins.txt \
    -r /wk/requirements.txt

$pip install \
    --find-links=/wheels/ \
    --no-cache-dir \
    -c /wk/bins.txt \
    -r /wk/requirements-odc.txt
