ARG base=opendatacube/geobase-builder:latest
FROM ${base}

ARG USER_NAME=ubuntu
ARG UID=1000

RUN adduser --disabled-password --gecos '' -u ${UID} ${USER_NAME} \
&& adduser ${USER_NAME} sudo \
&& echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /wk

CMD ["/bin/bash"]
