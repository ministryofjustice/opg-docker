FROM registry.service.opg.digital/opguk/jre-80x644

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g 3999 elasticsearch && useradd -m -u 3999 -g 3999 elasticsearch

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

# Define software versions
ENV ELASTICSEARCH_REPO_BASE https://artifacts.elastic.co/packages/5.x/apt
ENV ELASTICSEARCH_VERSION 5.4.0
# ES 16.04 issue
ENV ES_SKIP_SET_KERNEL_PARAMETERS true

# Define this confd variable here so we can use it early
ENV ELASTICSEARCH_PATH_REPO /usr/share/elasticsearch/repo

RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN apt-get update \
  && apt-get install elasticsearch=${ELASTICSEARCH_VERSION} \
  && pip install elasticsearch-curator \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/elasticsearch/config

# Make and set owner/group on path repo here as if not directory ends up as root:root regardless of later chown/chgrp
RUN mkdir -p $ELASTICSEARCH_PATH_REPO
RUN chown elasticsearch $ELASTICSEARCH_PATH_REPO
RUN chgrp elasticsearch $ELASTICSEARCH_PATH_REPO

EXPOSE 9200 9300

# Provide default values for confd
ENV HOME /usr/share/elasticsearch
ENV PATH $HOME/bin:$PATH
ENV ELASTICSEARCH_NUMBER_OF_REPLICAS 0
ENV ELASTICSEARCH_NETWORK_BIND_HOST 0.0.0.0
ENV ELASTICSEARCH_SCRIPT_DISABLE_DYNAMIC true
ENV ELASTICSEARCH_PATH_DATA /usr/share/elasticsearch/data
ENV ELASTICSEARCH_DISCOVERY_ZEN_MINIMUM_MASTER_NODES 1
ENV ELASTICSEARCH_CLUSTER_NAME opg
ENV ELASTICSEARCH_CLUSTER_NODES_ONE elasticsearch
ENV ELASTICSEARCH_NODE_NAME elasticsearch
ENV ELASTICSEARCH_INDICES_FIELDDATA_CACHE_SIZE 40%
ENV ELASTICSEARCH_GATEWAY_EXPECTED_NODES 1
ENV ELASTICSEARCH_GATEWAY_RECOVER_AFTER_TIME 5m
ENV ELASTICSEARCH_GATEWAY_RECOVER_AFTER_NODES 1
ENV ELASTICSEARCH_CLOUD_AWS_REGION eu-west-1
ENV ELASTICSEARCH_CLOUD_AWS_S3_PROTOCOL https
ENV ELASTICSEARCH_CLOUD_AWS_ACCESSKEY=
ENV ELASTICSEARCH_CLOUD_AWS_SECRETKEY=
ENV ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE s3
ENV ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME snapshot_repo
ENV ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET snapshots
ENV ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH /
ENV ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH $ELASTICSEARCH_PATH_REPO/snapshots
ENV ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS 7

VOLUME $ELASTICSEARCH_PATH_DATA
VOLUME $ELASTICSEARCH_PATH_REPO

# Extra chown/chgrp needed here otherwise volume remains root:root
RUN chown elasticsearch $ELASTICSEARCH_PATH_REPO
RUN chgrp elasticsearch $ELASTICSEARCH_PATH_REPO

ADD docker/confd /etc/confd
ADD docker/opt /opt
ADD docker/service/elasticsearch /etc/sv/elasticsearch
RUN mkdir -p /scripts/elasticsearch $HOME/config/scripts $HOME/logs
ADD docker/scripts /scripts/elasticsearch
ADD docker/my_init.d /etc/my_init.d

RUN chmod a+x /etc/my_init.d/*
RUN chmod -R a+x /etc/sv/elasticsearch/run
RUN chmod -R a+x /scripts/elasticsearch
RUN chmod -R a+x /opt

RUN  ln -s /etc/sv/elasticsearch /etc/service/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/elastic-scripts.log

ENV OPG_SERVICE elasticsearch
