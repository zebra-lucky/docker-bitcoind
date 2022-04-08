FROM ubuntu:bionic
MAINTAINER <zebra.lucky@gmail.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /bitcoin

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
RUN groupadd -g ${GROUP_ID} bitcoin
RUN useradd -u ${USER_ID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

RUN chown bitcoin:bitcoin -R /bitcoin
RUN apt-get update && apt-get install -y wget vim less net-tools git python3 \
    && version=22.0 \
    && download_url=https://bitcoin.org/bin/ \
    && version_path=bitcoin-core-${version}/ \
    && tar_file=bitcoin-${version}-x86_64-linux-gnu.tar.gz \
    && sum=59ebd25dd82a51638b7a6bb914586201e67db67b919b2a1ff08925a7936d1b16 \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp/ \
    && wget ${download_url}${version_path}${tar_file} \
    && echo $sum $tar_file | sha256sum -c \
    && tar -xzvf ${tar_file} \
    && cp /tmp/bitcoin-*/bin/*  /usr/local/bin \
    && cp /tmp/bitcoin-*/lib/*  /usr/local/lib \
    && rm -rf /tmp/bitcoin-*

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# For some reason, docker.io (0.9.1~dfsg1-2) pkg in Ubuntu 14.04 has permission
# denied issues when executing /bin/bash from trusted builds.  Building locally
# works fine (strange).  Using the upstream docker (0.11.1) pkg from
# http://get.docker.io/ubuntu works fine also and seems simpler.
USER bitcoin

VOLUME ["/bitcoin"]

EXPOSE 18332 18333

WORKDIR /bitcoin

CMD ["btc_oneshot"]
