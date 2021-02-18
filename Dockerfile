FROM rocker/tidyverse:4.0.3 AS base
LABEL maintainer="edjee@uchicago.edu"

ENV DEBIAN_FRONTEND noninteractive

COPY rstudio-prefs.json /home/rstudio/.config/

FROM base AS apt-get

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \ 
	libv8-dev \
	apt-utils \
	ed \
	libnlopt-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/

FROM apt-get AS rstan-config
RUN mkdir -p $HOME/.R/ \ 
  && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined" >> $HOME/.R/Makevars \
  && echo "CXXFLAGS+=-flto -Wno-unused-local-typedefs" >> $HOME/.R/Makevars \
  && echo "CXXFLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations" >> $HOME/.R/Makevars \
  && echo "rstan::rstan_options(auto_write = TRUE)" >> /home/rstudio/.Rprofile \
  && echo "options(mc.cores = min(4, parallel::detectCores()))" >> /home/rstudio/.Rprofile

# Install rstan
RUN install2.r --error --deps TRUE \
    V8 \	
    rstan 

FROM rstan-config AS install-r
COPY install.R /home/rstudio/
RUN chown -R  rstudio /home/rstudio/

RUN if [ -f /home/rstudio/install.R ]; then R --quiet -f /home/rstudio/install.R; fi


RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

