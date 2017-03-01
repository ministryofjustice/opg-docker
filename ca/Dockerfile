FROM registry.service.opg.digital/opguk/base:0.0.21-dev

RUN mkdir -p /data/cfssl

ADD  docker/confd /etc/confd
ADD  docker/my_init.d  /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*
