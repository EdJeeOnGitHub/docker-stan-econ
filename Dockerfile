FROM rocker/tidyverse:4.0.4 AS base
LABEL maintainer="edjee@uchicago.edu"

COPY rstudio-prefs.json /home/rstudio/.config/

FROM base AS apt-get
RUN  apt-get update -qq \ 
  && apt-get -y install apt-utils libgit2-dev libssh2-1-dev libv8-dev \
  libxml2-dev build-essential ed pkg-config apt-utils libglu1-mesa-dev \
  libnlopt-dev nano libgsl-dev libz-dev

FROM apt-get AS rstan-config
RUN mkdir -p $HOME/.R/ \ 
  && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined" >> $HOME/.R/Makevars \
  && echo "CXXFLAGS+=-flto -Wno-unused-local-typedefs" >> $HOME/.R/Makevars \
  && echo "CXXFLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations" >> $HOME/.R/Makevars \
  && echo "rstan::rstan_options(auto_write = TRUE)" >> /home/rstudio/.Rprofile \
  && echo "options(mc.cores = min(4, parallel::detectCores()))" >> /home/rstudio/.Rprofile

FROM base as install-r
COPY install.R /home/rstudio/
RUN chown -R  rstudio /home/rstudio/

RUN if [ -f /home/rstudio/install.R ]; then R --quiet -f /home/rstudio/install.R; fi


RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds
