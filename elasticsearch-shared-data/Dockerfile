FROM registry.service.opg.digital/opguk/base

VOLUME ["/tmp/elasticsearchshareddata"]

ENV BEATS_DASHBOARD_VERSION=5.2.2

COPY ./docker/templates/*beats-dashboards*/* /tmp/elasticsearchshareddata/beats/

RUN cd /tmp && \
   wget https://artifacts.elastic.co/downloads/beats/beats-dashboards/beats-dashboards-${BEATS_DASHBOARD_VERSION}.zip && \
   unzip beats-dashboards-${BEATS_DASHBOARD_VERSION}.zip && \
   cd beats-dashboards-${BEATS_DASHBOARD_VERSION} && \
   cp -r metricbeat/* /tmp/elasticsearchshareddata/beats && \
   rm -rf /tmp/beats-dashboards-*

RUN  chmod -R 644 /tmp/elasticsearchshareddata

USER root
ENV  HOME /root


