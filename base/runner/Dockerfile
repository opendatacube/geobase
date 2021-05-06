ARG base=opendatacube/geobase:builder
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

# TODO: we don't really need .deb files polluting this docker image, but alternatives are annoying to use
#  A. Run http server that would serve *deb packages and fetch from there
#  B. Copy installed files instead of .deb (need to know which ones)
#  C. Use experimental docker features: `RUN --mount=type=cache,ro,from=builder,source=/opt,target=/opt ...`
COPY --from=builder /opt/*deb /opt/
RUN echo "Installing geo libs" \
  && dpkg -i /opt/libkea*deb \
  && dpkg -i /opt/liblerc*deb \
  && dpkg -i /opt/libproj*deb \
  && dpkg -i /opt/libgdal*deb \
  && ldconfig \
  && echo "Done"

RUN echo "Run smoke test" \
  && gdal-config --version \
  && gdal-config --formats \
  && gdalinfo --version \
  && kea-config --version \
  && projinfo "epsg:4326" \
  && projinfo "epsg:3577" \
  && echo "Done"
