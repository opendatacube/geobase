#syntax=docker/dockerfile:1.2

# NOTE: Global Build Args shared between stages are odd
############################################################
#  Default value is set here, before first FROM
#  But you still need to add
#    ARG py_env_path
#  without default value in every stage that uses it,
#  BEFORE it is used, ideally JUST BEFORE, to help with
#  docker layer caching
ARG py_env_path=/env
ARG V_BASE=latest

# Basically env_builder stage should not need to change from service to service
#   only change content of requirement.txt
#  1. Copy requirements.txt
#  2. Download/compile/re-use all the wheels
#  3. Build environment from wheels
FROM opendatacube/geobase-builder:${V_BASE} as env_builder

COPY requirements.txt constraints.txt nobinary.txt /conf/

# build wheels in cached directory to allow re-use even when requirements.txt is changed
# then copy to final location
#   /root/.cache/pip  <-- pip cache
#   /var/cache/wheels <-- downloaded sources and compiled wheels
#   /wheels           <-- final destination copied from /var/cache/wheels cache
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/var/cache/wheels \
    mkdir /wheels \
    && NOBINARY=/conf/nobinary.txt env-build-tool wheels /conf/requirements.txt /conf/constraints.txt /var/cache/wheels \
    && python3 -m pip wheel \
    -r /conf/requirements.txt \
    --find-links /var/cache/wheels \
    --no-index \
    --only-binary=:all: \
    --wheel-dir /wheels


#--------------------------------------------------------------------------------
# Runner stage might need changing if extra Ubuntu packages are needed for
# different purposes
# --------------------------------------------------------------------------------
FROM opendatacube/geobase-runner:${V_BASE}
ENV LC_ALL=C.UTF-8

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

RUN useradd -m -s /bin/bash -N odc

COPY --from=env_builder /bin/tini /bin/tini

# tell docker we are about to use py_env_path global build argument
# you should not set default value here, it is defined up top.
ARG py_env_path
RUN install -d -o odc -g users ${py_env_path}
# Copy python env
RUN --mount=type=bind,from=env_builder,target=/b \
    env-build-tool new_no_index /b/conf/requirements.txt /b/conf/constraints.txt ${py_env_path} /b/wheels

ENV PATH="$py_env_path/bin:$PATH"
USER odc

ENTRYPOINT ["/bin/tini", "-s", "--", "with_bootstrap"]
