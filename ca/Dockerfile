#FROM registry.service.opg.digital/opguk/base
# @TODO temporarily build off our docker-compose base.
FROM ca_base

RUN mkdir -p /data/cfssl


ADD  docker/confd /etc/confd
ADD  docker/my_init.d  /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*
