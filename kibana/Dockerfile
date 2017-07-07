FROM registry.service.opg.digital/opguk/base
ARG ES_VERSION=5.3.0
# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -g kibana kibana

RUN apt-get update && apt-get install -y ca-certificates curl --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Define software versions
ENV ELASTICSEARCH_REPO_BASE https://artifacts.elastic.co/packages/5.x/apt
RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN apt-get update \
  && apt-get install kibana=${ES_VERSION} \
  && rm -rf /var/lib/apt/lists/*

ENV PORT 5601
ENV HOST 0.0.0.0
ENV ELASTICSEARCH elasticsearch
ENV ELASTICSEARCH_PORT_9200_TCP 9200
ENV ELASTICSEARCH_PRESERVE_HOST true
ENV KIBANA_INDEX .kibana
ENV DEFAULT_APP_ID discover
ENV REQUEST_TIMEOUT 300000
ENV SHARD_TIMEOUT 0
ENV VERIFY_SSL true

EXPOSE 5601

ADD docker/confd /etc/confd

ADD docker/service/kibana /etc/sv/kibana
RUN chmod a+x /etc/sv/kibana/run
RUN  ln -s /etc/sv/kibana /etc/service/

ENV OPG_SERVICE kibana
