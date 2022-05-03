# Build odr-audioenc
FROM ubuntu:22.04 AS builder-audio
ARG  URL_BASE=https://github.com/Opendigitalradio
ARG  SOFTWARE=ODR-AudioEnc/archive/refs/tags
ARG  VERSION=v3.2.0
ENV  DEBIAN_FRONTEND=noninteractive
## Update system
RUN  apt-get update \
     && apt-get upgrade --yes
## Install build packages
RUN  apt-get install --yes \
          autoconf \
          build-essential \
          curl \
          pkg-config
## Install development libraries and build
RUN  apt-get install --yes \
          libasound2-dev \
          libcurl4-openssl-dev \
          libgstreamer1.0-dev \
          libgstreamer-plugins-base1.0-dev \
          libjack-jackd2-dev \
          libvlc-dev \
          libzmq3-dev \
     && cd /root \
     && curl -L ${URL_BASE}/${SOFTWARE}/${VERSION}.tar.gz | tar -xz \
     && cd ODR* \
     && ./bootstrap \
     && ./configure --enable-alsa --enable-jack --enable-vlc --enable-gst \
     && make \
     && make install

# Build odr-padenc
FROM ubuntu:22.04 AS builder-pad
ARG  URL_BASE=https://github.com/Opendigitalradio
ARG  SOFTWARE=ODR-PadEnc/archive/refs/tags
ARG  VERSION=v3.0.0
ENV  DEBIAN_FRONTEND=noninteractive
## Update system
RUN  apt-get update \
     && apt-get upgrade --yes
## Install build packages
RUN  apt-get install --yes \
          autoconf \
          build-essential \
          curl \
          pkg-config
## Install development libraries and build
RUN  apt-get install --yes \
          libmagickwand-6.q16-dev \
     && cd /root \
     && curl -L ${URL_BASE}/${SOFTWARE}/${VERSION}.tar.gz | tar -xz \
     && cd ODR* \
     && ./bootstrap \
     && ./configure \
     && make \
     && make install

# Build the final image
FROM ubuntu:22.04
ENV  DEBIAN_FRONTEND=noninteractive
## Update system
RUN  apt-get update \
     && apt-get upgrade --yes
## Copy objects built in the builder phase
COPY --from=builder-audio /usr/local/bin/odr-audioenc /usr/bin/
COPY --from=builder-pad /usr/local/bin/odr-padenc /usr/bin/
COPY start /usr/local/bin/
## Install production libraries, supervisor and customize
RUN  chmod 0755 /usr/local/bin/start \
     && apt-get install --yes \
          gstreamer1.0-plugins-good \
          libasound2 \
          libmagickwand-6.q16-dev \
          libcurl4 \
          libgstreamer1.0 \
          libgstreamer-plugins-base1.0 \
          libjack0 \
          libvlc5 vlc-plugin-base \
          libzmq5 \
          supervisor \
     && rm -rf /var/lib/apt/lists/* \
     && echo '' >> /etc/supervisor/supervisord.conf \
     && echo '[inet_http_server]' >> /etc/supervisor/supervisord.conf \
     && echo 'port = 8001' >> /etc/supervisor/supervisord.conf \
     && echo 'username = odr' >> /etc/supervisor/supervisord.conf \
     && echo 'password = odr' >> /etc/supervisor/supervisord.conf

EXPOSE 8001
ENTRYPOINT ["start"]
LABEL org.opencontainers.image.vendor="Open Digital Radio"
LABEL org.opencontainers.image.description="Audio and PAD encoders"
LABEL org.opencontainers.image.authors="robin.alexander@netplus.ch"