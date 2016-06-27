FROM registry.service.dsd.io/opguk/base:latest

VOLUME ["/tmp/elasticsearchshareddata"]

COPY ./docker/templates/*beats-dashboards*/* /tmp/elasticsearchshareddata/beats/
COPY ./docker/templates/*beats-dashboards*/* /tmp/elasticsearchshareddata/cheese/

RUN  chmod -R 644 /tmp/elasticsearchshareddata

USER root
ENV  HOME /root


