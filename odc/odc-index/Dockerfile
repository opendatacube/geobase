#syntax=docker/dockerfile:1.2
ARG py_env_path=/env
ARG V_BASE=latest

# Basically env_builder stage should not need to change from service to service
#   only change content of requirement.txt
#  1. Copy requirements.txt
#  2. Download/compile/re-use all the wheels
#  3. Build environment from wheels
FROM opendatacube/geobase-builder:${V_BASE} as env_builder

RUN mkdir -p /conf
COPY requirements.txt /conf/
COPY constraints.txt /conf/
ARG py_env_path
RUN --mount=type=cache,target=/root/.cache/pip \
    mkdir /wheels \
    &&  env-build-tool wheels /conf/requirements.txt /conf/constraints.txt /wheels

#--------------------------------------------------------------------------------
# Runner stage might need changing if extra Ubuntu packages are needed for
# different purposes
# --------------------------------------------------------------------------------
FROM opendatacube/geobase-runner:${V_BASE}

# This step might require customization
RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
  # developer convenience
  postgresql-client-12 \
  less \
  vim \
  git \
  tmux \
  && rm -rf /var/lib/apt/lists/*

COPY with_bootstrap /bin/
ENV LC_ALL=C.UTF-8 \
    PATH="$py_env_path/bin:$PATH"

RUN useradd -m -s /bin/bash -N odc
ARG py_env_path
RUN install -d -o odc -g users ${py_env_path}

# Copy python env, tini
COPY --from=env_builder /bin/tini /bin/tini
RUN --mount=type=bind,from=env_builder,target=/b \
    env-build-tool new_no_index /b/conf/requirements.txt /b/conf/constraints.txt ${py_env_path} /b/wheels

USER odc

ENTRYPOINT ["/bin/tini", "-s", "--", "with_bootstrap"]
