# Build odr-audioenc
FROM debian:bullseye-slim AS builder-audio
ARG  DEBIAN_FRONTEND=noninteractive
RUN  apt-get update && \
     apt-get upgrade --yes && \
     apt-get install --yes \
          apt-utils
RUN  apt-get install --yes \
          automake \
          build-essential \
          curl \
          git \
          libtool \
          pkg-config
RUN  apt-get install --yes \
          libasound2-dev \
          libcurl4-openssl-dev \
          libgstreamer1.0-dev \
          libgstreamer-plugins-base1.0-dev \
          libjack-jackd2-dev \
          libvlc-dev \
          libzmq3-dev  
ARG  URL=ODR-AudioEnc/archive/refs/tags/v3.2.0.tar.gz
RUN  cd /root && \
     curl -L https://github.com/Opendigitalradio/${URL} | tar -xz && \
     cd ODR* && \
     ./bootstrap && \
     ./configure --enable-alsa --enable-jack --enable-vlc --enable-gst && \
     make && make install 

# Build odr-padenc
FROM debian:bullseye-slim AS builder-pad
ARG  DEBIAN_FRONTEND=noninteractive
RUN  apt-get update && \
     apt-get upgrade --yes && \
     apt-get install --yes \
          apt-utils
RUN  apt-get install --yes \
          automake \
          build-essential \
          curl \
          git \
          libtool \
          pkg-config
RUN  apt-get install --yes \
          libmagickwand-6.q16-dev
ARG  URL=ODR-PadEnc/archive/refs/tags/v3.0.0.tar.gz
RUN  cd /root && \
     curl -L https://github.com/Opendigitalradio/${URL} | tar -xz && \
     cd ODR* && \
     ./bootstrap && \
     ./configure && \
     make && make install 

# Build the final image
FROM debian:bullseye-slim
ARG  DEBIAN_FRONTEND=noninteractive
## Update system
RUN  apt-get update && \
     apt-get upgrade --yes && \
     apt-get install --yes \
          apt-utils
## Install specific packages
RUN  apt-get install --yes \
          libasound2 \
          libmagickwand-6.q16-dev \
          libcurl4 \
          libgstreamer1.0 \
          libgstreamer-plugins-base1.0 \
          gstreamer1.0-plugins-good \
          libjack0 \
          libvlc5 vlc-plugin-base \
          libzmq5 \
          supervisor && \
     rm -rf /var/lib/apt/lists/* 
## Document image
LABEL org.opencontainers.image.vendor="Open Digital Radio" 
LABEL org.opencontainers.image.description="Audio and PAD encoders" 
LABEL org.opencontainers.image.authors="robin.alexander@netplus.ch" 
## Copy objects built in the builder phase
COPY --from=builder-audio /usr/local/bin/odr-audioenc /usr/bin/
COPY --from=builder-pad /usr/local/bin/odr-padenc /usr/bin/
COPY start /usr/local/bin/
## Customization
RUN  chmod 0755 /usr/local/bin/start && \
     echo '' >> /etc/supervisor/supervisord.conf && \
     echo '[inet_http_server]' >> /etc/supervisor/supervisord.conf && \
     echo 'port = 8001' >> /etc/supervisor/supervisord.conf && \
     echo 'username = odr' >> /etc/supervisor/supervisord.conf && \
     echo 'password = odr' >> /etc/supervisor/supervisord.conf
EXPOSE 8001
ENTRYPOINT ["start"]