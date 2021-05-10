ARG V_BASE=3.3.0

FROM opendatacube/geobase-builder:${V_BASE} as env_builder
COPY requirements.txt /
COPY constraints.txt /
RUN env-build-tool new /requirements.txt /constraints.txt /env


FROM opendatacube/geobase-runner:${V_BASE}
COPY --from=env_builder /env /env
ENV LC_ALL=C.UTF-8
ENV PATH="/env/bin:${PATH}"
