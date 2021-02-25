FROM opendatacube/geobase:builder as env_builder
COPY requirements.txt /
RUN env-build-tool new /requirements.txt /env


FROM opendatacube/geobase:runner
COPY --from=env_builder /env /env
ENV LC_ALL=C.UTF-8
ENV PATH="/env/bin:${PATH}"
