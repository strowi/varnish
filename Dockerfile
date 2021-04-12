FROM ubuntu:20.04
LABEL maintainer="Roman v. Gemmeren <strowi@hasnoname.de>"

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
ARG BUILD_DEPS=" \
      curl \
      gnupg \
      ca-certificates \
      apt-transport-https \
      git \
      build-essential \
      libtool \
      make \
      automake \
      autotools-dev \
      pkg-config \
      python3-docutils \
      python3-sphinx"

ARG DUMB_INIT_VERSION="1.2.2"
ARG VARNISH_VERSION="6.0.7*"
ARG VARNISH_MODULES_TAG=6.0-lts
ARG VMOD_RE_VERSION=6.0
ARG VARNISH_EXPORTER_VERSION=1.5.2

ENV VCL_CONFIG /etc/varnish/default.vcl
ENV CACHE_SIZE 1g
ENV VARNISHD_PARAMS -p default_ttl=120 -p default_grace=3600

RUN apt-get update -qqy \
  && apt-get install -qqy --no-install-recommends \
    $BUILD_DEPS \
  && curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 \
  && chmod +x /usr/local/bin/dumb-init \
  && curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | apt-key add - \
  && echo "deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ focal main" > /etc/apt/sources.list.d/varnish.list \
  && echo "deb-src https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ focal main " >> /etc/apt/sources.list.d/varnish.list \
  && apt-get update -qq \
  && apt-get install -qqy \
    netbase \
    varnish=${VARNISH_VERSION} \
    varnish-dev=${VARNISH_VERSION} \
  # install varnish-modules
  && cd /usr/src \
    && git clone --depth=1 --branch $VARNISH_MODULES_TAG https://github.com/varnish/varnish-modules.git \
    && cd varnish-modules \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make -j4 \
    && make -j4 check \
    && make install \
  # + libvmod-re
  &&  cd /usr/src \
    && git clone --depth=1 --branch $VMOD_RE_VERSION https://code.uplex.de/uplex-varnish/libvmod-re.git \
    && cd /usr/src/libvmod-re \
    && ./autogen.sh \
    && ./configure --disable-dependency-tracking \
    && make -j4 \
    && make -j4 check \
    && make install \
  # + varnish-exporter
  && cd /usr/local/bin \
    && curl -sL https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/${VARNISH_EXPORTER_VERSION}/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz \
      |tar xz --strip-components=1 \
  # && apt-get -y clean \
  && apt-get purge -y \
    $BUILD_DEPS \
    varnish-dev \
  && apt-get -y autoremove \
  && rm -fr \
    /usr/local/share/doc \
    /usr/local/share/man \
    /usr/src/* \
    /tmp/* \
    /var/lib/apt/* \
    /var/cache/* \
    /var/tmp/* \
    /var/log/*

# RUN ln -s "lg_dirty_mult:8,lg_chunk:18" /etc/malloc.conf

COPY src/ /

EXPOSE 80
VOLUME /var/lib/varnish

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/docker-entrypoint.sh"]
