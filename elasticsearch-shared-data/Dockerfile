FROM registry.service.opg.digital/opguk/base

RUN mkdir -p /tmp/elasticsearchshareddata/beats

ENV BEATS_DASHBOARD_VERSION=5.2.2

COPY ./docker/templates/*beats-dashboards*/* /tmp/elasticsearchshareddata/beats/

RUN cd /tmp && \
   wget https://artifacts.elastic.co/downloads/beats/beats-dashboards/beats-dashboards-${BEATS_DASHBOARD_VERSION}.zip && \
   unzip beats-dashboards-${BEATS_DASHBOARD_VERSION}.zip

RUN cd /tmp/beats-dashboards-${BEATS_DASHBOARD_VERSION} && \
   cp -rv metricbeat/* /tmp/elasticsearchshareddata/beats && \
   cp -rv filebeat/* /tmp/elasticsearchshareddata/beats

RUN rm -rf /tmp/beats-dashboards-* && \
   chmod -R 644 /tmp/elasticsearchshareddata

VOLUME /tmp/elasticsearchshareddata

USER root
ENV  HOME /root


