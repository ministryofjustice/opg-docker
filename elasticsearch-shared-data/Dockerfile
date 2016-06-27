FROM registry.service.dsd.io/opguk/elasticsearch:latest

VOLUME ["/tmp/elasticsearchshareddata"]

COPY ./docker/templates/*beats-dashboards*/* /tmp/elasticsearchshareddata/beats/

RUN  chmod -R 644 /tmp/elasticsearchshareddata

USER root
ENV  HOME /root


