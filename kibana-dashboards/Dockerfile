FROM registry.service.dsd.io/opguk/base:latest

VOLUME ["/tmp/dashboards"]

COPY ./docker/templates/*beats-dashboards*/* /tmp/dashboards/beats/

RUN  chmod -R 644 /tmp/dashboards

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

USER root
ENV  HOME /root


