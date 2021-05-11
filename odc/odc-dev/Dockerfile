ARG V_BASE=3.3.0
FROM opendatacube/geobase-builder:${V_BASE}

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
  # developer convenience
  postgresql-client-12 \
  postgresql-12 \
  less \
  wget \
  curl \
  vim \
  tmux \
  htop \
  fish \
  tig \
  git \
  silversearcher-ag \
  openssh-client \
  sudo \
  # datacube tests need redis
  redis-server \
  && rm -rf /var/lib/apt/lists/*

ARG py_env_path=/env
ENV nb_user=odc

RUN install --owner "${nb_user}" -D -d /nb \
&&  install --owner "${nb_user}" -D -d /src \
&&  install --owner "${nb_user}" -D -d "${py_env_path}"

# First process base requirements
#   this will just download/build
#   /wheels/ should contain all the wheels needed to construct base environment
COPY conf/requirements.txt /conf/
COPY conf/constraints.txt /conf/
RUN env-build-tool wheels /conf/requirements.txt /conf/constraints.txt /wheels

# this will be used by integration tests
COPY assets/datacube_integration.conf /conf/

# install scripts
COPY assets/odc-entry-point  /bin/
COPY assets/build_env.sh     /bin/

# copy over further environment configs
COPY conf/requirements-odc.txt      /conf/
COPY conf/lab-extensions.txt        /conf/
COPY conf/lab-server-extensions.txt /conf/

USER $nb_user

ENV HOME="/home/${nb_user}" \
    PYENV="${py_env_path}" \
    PATH=$HOME/.local/bin:$PATH

# /env volume contains python virtual env
VOLUME ["${py_env_path}"]

# /src volume is for libs installed in edit mode
#  The idea is to edit code outside of this docker and see changes immediately
VOLUME ['/src']

# /nb volume is for notebooks
VOLUME ['/nb']

# home folder is a volume: jupyter/shell config will persist here
VOLUME ["${HOME}"]

# /run/postgresql volume allows access to db running on the host
VOLUME ['/run/postgresql']

# non-default port to not clash with jupyter you might be running already
ARG nb_port=9988
ENV NB_PORT="${nb_port}"
EXPOSE "${nb_port}"

WORKDIR "${HOME}"
ENTRYPOINT ["/bin/tini", "-s", "--", "with_bootstrap", "odc-entry-point"]

CMD ["bash"]
