FROM phusion/baseimage:0.9.16

# Set correct HOME
ENV HOME /root

# For debconf not to complain
ENV DEBIAN_FRONTEND noninteractive

# Ensure that all packages are latest and use AWS EU mirror
# Basic packages
# Log aggregation
ADD  docker/sources.list /etc/apt/sources.list
RUN  rm -f /etc/apt/sources.list.d/*
RUN  apt-get update && apt-get -y upgrade && apt-get install -y git joe && \
     apt-get install -y awscli && \
     apt-get install -y python python-pip && pip install Beaver==33.1.0 && \
     apt-get install -y wget && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

# ConfD install
RUN  wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.9.0/confd-0.9.0-linux-amd64 && \
     chmod a+x /usr/bin/confd && \
     mkdir -p /etc/confd/conf.d && \
     mkdir -p /etc/confd/templates

# Locale
RUN  locale-gen en_GB en_GB.UTF-8

# Let's disable ssh access (on phusion/baseimage:0.9.16 you still need to remove server key)
RUN  rm /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN  rm -Rf /etc/service/sshd

# Application user and location
RUN  useradd -m -d /app app
RUN  mkdir -p /var/log/app && chown app /var/log/app
RUN  mkdir -p /data && chown app /data
RUN  mkdir -p /var/run/app && chown app /var/run/app

ADD  docker/service/beaver /etc/service/beaver
RUN  chmod a+x /etc/service/beaver/run

ADD  docker/beaver.conf /etc/beaver.conf

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*
