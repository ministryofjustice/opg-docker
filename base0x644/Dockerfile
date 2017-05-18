FROM phusion/baseimage:0.9.21

# Set correct HOME
ENV HOME /root
ARG GOSU_VERSION=1.10
ARG CONFD_VERSION=0.11.0

# For debconf not to complain
ENV DEBIAN_FRONTEND noninteractive

# Ensure that all packages are latest and use AWS EU mirror
# Basic packages
# Log aggregation
# Set --no-install-recommends as our default
ADD docker/01norecommend /etc/apt/apt.conf.d/01norecommend
ADD docker/sources.list /etc/apt/sources.list

RUN gpg --keyserver hkp://ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download//${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

ARG APT_PACKAGES="dos2unix git python-setuptools wget dnsmasq unzip zip"

RUN  rm -f /etc/apt/sources.list.d/* && \
     apt update && \
     apt install -y apt-utils && \
     apt -y upgrade && \
     apt install -y ${APT_PACKAGES} && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

# Pip installs
# Install awscli to override the system one which is broken (with python 3.4.3 as of Sept 2015)
RUN easy_install pip && pip install -U pip && pip install awscli Beaver

# ConfD install
RUN  wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
     chmod a+x /usr/bin/confd && \
     mkdir -p /etc/confd/conf.d && \
     mkdir -p /etc/confd/templates

# Locale
RUN  locale-gen en_GB en_GB.UTF-8

# Let's disable ssh access (on phusion/baseimage:0.9.16 you still need to remove server key)
RUN  rm /etc/my_init.d/00_regen_ssh_host_keys.sh && \
     rm -rf /etc/service/sshd || true

# Application user and location
RUN  useradd -m -d /app app && \
     mkdir -p /var/log/app /data /var/run/app && chown app /var/log/app /data /var/run/app

ADD  docker/service/beaver /etc/sv/beaver
RUN  chmod a+x /etc/sv/beaver/run && \
     ln -s /etc/sv/beaver /etc/service/ && \
     mkdir -p /etc/beaver.d

# Provide a resolver at localhost for software that can't/won't use /etc/resolv.conf
ADD  docker/service/dnsmasq /etc/service/dnsmasq
RUN  chmod a+x /etc/service/dnsmasq/run

# disable MTU on vixie cron
ADD  docker/cron/crontab /etc/crontab
ADD  docker/cron/root /var/spool/cron/crontabs/root
RUN  chmod 600 /var/spool/cron/crontabs/root
ADD  docker/cron/app /var/spool/cron/crontabs/app
RUN  chown app:crontab /var/spool/cron/crontabs/app && chmod 600 /var/spool/cron/crontabs/app

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

ADD  docker/confd /etc/confd

RUN mkdir -p /scripts/base
ADD docker/scripts /scripts/base
RUN chmod -R a+x /scripts/base

ENV OPG_SERVICE base
