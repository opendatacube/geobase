ARG py_env_path=/env

# Basically env_builder stage should not need to change from service to service
#   only change content of requirement.txt
#  1. Copy requirements.txt
#  2. Download/compile/re-use all the wheels
#  3. Build environment from wheels
FROM opendatacube/geobase:wheels as env_builder
ARG py_env_path

RUN mkdir -p /conf
COPY requirements.txt /conf/
RUN env-build-tool wheels /conf/requirements.txt /wheels
RUN env-build-tool new /conf/requirements.txt /wheels ${py_env_path}

# we need a better place for this thing, maybe even package it properly
RUN curl -s -L https://raw.githubusercontent.com/opendatacube/geobase/51649f75d5250bd3bba08c6a283da0269f10c3b9/odc-dev/dc_config_render.py > /bin/dc_config_render.py \
&& chmod 755 /bin/dc_config_render.py


#--------------------------------------------------------------------------------
# Runner stage might need changing if extra Ubuntu packages are needed for different purposes
#--------------------------------------------------------------------------------
FROM opendatacube/geobase:runner
ARG py_env_path

# Copy python env
COPY --from=env_builder $py_env_path $py_env_path

# Install Tini
COPY --from=env_builder /bin/tini /bin/tini
COPY --from=env_builder /bin/dc_config_render.py /bin/

# This step might require customization
RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
  # developer convenience
  postgresql-client-10 \
  less \
  vim \
  git \
  && rm -rf /var/lib/apt/lists/*

COPY with_bootstrap /bin/
ENV LC_ALL=C.UTF-8 \
    PATH="$py_env_path/bin:$PATH"

RUN useradd -m -s /bin/bash -N dcuser
USER dcuser

ENTRYPOINT ["/bin/tini", "-s", "--", "with_bootstrap"]
