ARG py_env_path=/env

FROM kkodc/geobase:wheels as builder
ARG py_env_path

RUN mkdir -p /wk \
&& find /wheels -type f -name "*whl" > /wk/bins.txt

COPY requirements.txt /wk/
RUN echo "Fetching wheels" \
  && mkdir -p /wk/wheels \
  # get all the wheels from requirements.txt, making sure pre-compiled wheels are used
  && pip wheel \
  --no-cache-dir \
  --find-links=/wheels \
  -c /wk/bins.txt \
  -r /wk/requirements.txt \
  -w /wk/wheels \
  && ls -lh /wk/wheels \
  && echo "====================================================="

RUN echo "Building python environment" \
  && mkdir -p ${py_env_path} \
  && python3 -m venv ${py_env_path} \
  && ${py_env_path}/bin/pip install --upgrade pip \
  && ${py_env_path}/bin/pip install \
  --find-links=/wk/wheels \
  --no-cache-dir \
  --no-index \
  -c /wk/bins.txt \
  -r /wk/requirements.txt \
  && echo "====================================================="

ENV PATH=${py_env_path}/bin:$PATH

RUN echo "Adding jupyter lab extensions" \
  && jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager@v1.0.2 \
  && jupyter labextension install --no-build @jupyterlab/geojson-extension@v1.0.0 \
  && jupyter labextension install --no-build @jupyterlab/hub-extension@v1.1.0 \
  && jupyter labextension install --no-build jupyter-leaflet@v0.11.1 \
  && jupyter labextension install --no-build dask-labextension@v1.0.1 \
  && jupyter labextension install --no-build jupyter-matplotlib@v0.4.2 \
  && jupyter labextension install --no-build jupyterlab_bokeh@v1.0.0 \
  && jupyter labextension install --no-build nbdime-jupyterlab@v1.0.0 \
  && jupyter labextension install --no-build @ryantam626/jupyterlab_code_formatter@v0.5.0 \
  && jupyter labextension install --no-build @jupyter-widgets/jupyterlab-sidecar@v0.4.0 \
  && jupyter labextension install --no-build ipyevents@v1.7.0 \
  && jupyter labextension install --no-build ipycanvas@v0.3.4 \
  && jupyter lab build \
  && jupyter labextension list \
  && echo "...done"

COPY requirements-odc.txt /wk/

RUN echo "Adding odc-dependencies" \
  && ${py_env_path}/bin/pip install \
  --find-links=/wk/wheels \
  --no-cache-dir \
  -c /wk/bins.txt \
  -r /wk/requirements-odc.txt \
  && echo "====================================================="


FROM kkodc/geobase:runner
ARG py_env_path
RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
  # developer convenience
  postgresql-client-10 \
  postgresql-10 \
  less \
  wget \
  curl \
  vim \
  tmux \
  htop \
  fish \
  tig \
  git \
  openssh-client \
  sudo \
&& rm -rf /var/lib/apt/lists/*

# Install Tini
COPY --from=builder /bin/tini /bin/tini

# Copy python env
COPY --from=builder $py_env_path $py_env_path

ENV LC_ALL=C.UTF-8
ENV PATH=${py_env_path}/bin:$PATH

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/bin/tini", "-s", "--", "docker-entrypoint.sh"]

ARG nb_user=jovyan
ARG nb_uid=1000
ARG nb_gid=100

RUN useradd -m -s /bin/bash -N -g $nb_gid -u $nb_uid $nb_user \
&& adduser ${nb_user} sudo \
&& echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN install --owner "${nb_user}" -D -d /conf

USER $nb_user

VOLUME ["/home/$nb_user"]
VOLUME ['/run/postgresql']
WORKDIR "/home/$nb_user"
EXPOSE 9988

CMD ["jupyter", "lab", \
"--ip=0.0.0.0", \
"--port=9988", \
"--no-browser"]
