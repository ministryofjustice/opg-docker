#FROM registry.service.opg.digital/opguk/base:0.0.21-dev

FROM ca_base

RUN mkdir -p /data/cfssl
ADD  docker/confd /etc/confd

ADD  docker/service/cfssl /etc/service/cfssl
RUN  chmod a+x /etc/service/cfssl/run


ENV SKIP_SSL_GENERATE=true
ENV SKIP_INSTALL_CA_CERT=true
