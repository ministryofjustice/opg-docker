FROM registry.service.dsd.io/opguk/base:latest

VOLUME ["/tmp/dashboards"]

ADD ./docker/templates/*beats-dashboards*/* /tmp/dashboards/beats/

RUN  chmod -R 644 /tmp/dashboards

USER root
ENV  HOME /root
