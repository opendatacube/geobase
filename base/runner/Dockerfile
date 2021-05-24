#syntax=docker/dockerfile:1.2
ARG base=opendatacube/geobase-builder
FROM ${base} as builder

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
  && apt-get install -y --fix-missing --no-install-recommends \
  python3 python3-dev python3-pip python3-venv \
  && rm -rf /var/lib/apt/lists/*

# GDAL/GEOS/PROJ dependencies
RUN apt-get update -y \
  && apt-get install -y --fix-missing --no-install-recommends \
  libopenjp2-7 \
  libzstd1 \
  libdeflate0 \
  liblzma5 \
  libcurl4 \
  libssl1.1 \
  libpq5 \
  libxml2 libexpat1 libxerces-c3.2 \
  libnetcdf-c++4 netcdf-bin \
  libhdf4-0-alt libhdf5-103 libhdf5-cpp-103 \
  libpcre3 \
  libkmlbase1 libkmlconvenience1 libkmldom1 libkmlengine1 libkmlregionator1 libkmlxsd1 \
  libyaml-0-2 \
  libatlas3-base \
  libgfortran4 \
  libgomp1 \
  libgmpxx4ldbl \
  libsqlite3-0 \
  libspatialindex-c6 \
  libspatialindex6 \
  libilmbase24 \
  libopenexr24 \
  libudunits2-0 \
  libtiff5 \
  libjpeg-turbo8 \
  libpng16-16 \
  libgif7 \
  libwebp6 \
  # GEO
  libgeos-3.8.0 \
  libgeos-c1v5 \
  libsfcgal1 \
  # PIL
  liblcms2-2 \
  # matplotlib
  libfreetype6 \
  && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,from=builder,target=/b \
  echo "Installing geo libs" \
  && dpkg -i /b/opt/libkea*deb \
  && dpkg -i /b/opt/liblerc*deb \
  && dpkg -i /b/opt/libproj*deb \
  && dpkg -i /b/opt/libgdal*deb \
  && ldconfig \
  && cp /b/opt/constraints-gdal.txt /opt/ \
  && cp /b/opt/compile-wheels.mk /opt/ \
  && cp /b/usr/local/bin/env-build-tool /usr/local/bin/env-build-tool \
  && echo "Done"

RUN echo "Run smoke test" \
  && gdal-config --version \
  && gdal-config --formats \
  && gdalinfo --version \
  && kea-config --version \
  && projinfo "epsg:4326" \
  && projinfo "epsg:3577" \
  && echo "Done"
