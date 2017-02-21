FROM phusion/baseimage:0.9.16

# Set correct HOME
ENV HOME /root

# For debconf not to complain
ENV DEBIAN_FRONTEND noninteractive

# Ensure that all packages are latest and use AWS EU mirror
# Basic packages
# Log aggregation
ADD  docker/sources.list /etc/apt/sources.list
RUN gpg --keyserver hkp://ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

RUN  rm -f /etc/apt/sources.list.d/* && \
     apt-get update && apt-get -y upgrade && apt-get install -y git joe && \
     apt-get install -y python python-pip && \
     apt-get install -y wget dnsmasq && \
     apt-get install -y unzip zip && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

# Pip installs
# Install awscli to override the system one which is broken (with python 3.4.3 as of Sept 2015)
RUN pip install -U pip && pip install awscli Beaver==36.2.0

# ConfD install
RUN  wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.9.0/confd-0.9.0-linux-amd64 && \
     chmod a+x /usr/bin/confd && \
     mkdir -p /etc/confd/conf.d && \
     mkdir -p /etc/confd/templates

# Locale
RUN  locale-gen en_GB en_GB.UTF-8

# Let's disable ssh access (on phusion/baseimage:0.9.16 you still need to remove server key)
RUN  rm /etc/my_init.d/00_regen_ssh_host_keys.sh && \
     unlink /etc/service/sshd || true && \
     rm -rf /etc/service/sshd || true

# Application user and location
RUN  useradd -m -d /app app && \
     mkdir -p /var/log/app /data /var/run/app && chown app /var/log/app /data /var/run/app

ADD  docker/service/beaver /etc/sv/beaver
RUN  chmod a+x /etc/sv/beaver/run && \
     ln -s /etc/sv/beaver /etc/service/ && \
     mkdir -p /etc/beaver.d

ADD  docker/beaver.conf /etc/beaver.conf

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

# cfssl
RUN wget -qO /usr/local/sbin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    && chmod +x  /usr/local/sbin/cfssl \
    && sha256sum /usr/local/sbin/cfssl | awk '$1!="eb34ab2179e0b67c29fd55f52422a94fe751527b06a403a79325fed7cf0145bd" {exit 1}'

RUN wget -qO /usr/local/sbin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 \
    && chmod +x  /usr/local/sbin/cfssljson \
    && sha256sum /usr/local/sbin/cfssljson | awk '$1!="1c9e628c3b86c3f2f8af56415d474c9ed4c8f9246630bd21c3418dbe5bf6401e" {exit 1}'

RUN mkdir -p /data/cfssl
