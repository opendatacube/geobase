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

# for jupyter lab builds
RUN apt-get update \
  && apt-get install -y \
  libssl1.0-dev nodejs-dev \
  && apt-get install -y libssl-dev \
  && apt-get install -y \
  npm \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

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
  && jupyter lab build \
  && jupyter labextension list \
  && echo "...done"


FROM kkodc/geobase:runner
ARG py_env_path
ARG nb_user=jovyan
ARG nb_uid=1000
ARG nb_gid=100

RUN useradd -m -s /bin/bash -N -u $nb_uid $nb_user

COPY --from=builder $py_env_path $py_env_path
ENV LC_ALL=C.UTF-8
ENV PATH=${py_env_path}/bin:$PATH

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

USER $nb_user

EXPOSE 9988

CMD ["jupyter", "lab", \
"--ip=0.0.0.0", \
"--port=9988", \
"--no-browser"]
