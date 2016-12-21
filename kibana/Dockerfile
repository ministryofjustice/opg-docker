FROM registry.service.opg.digital/opguk/base


# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -g kibana kibana

RUN apt-get update && apt-get install -y ca-certificates curl --no-install-recommends && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION=1.10
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN arch="$(dpkg --print-architecture)" \
	&& set -x \
	&& curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$arch" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$arch.asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

ENV KIBANA_VERSION 4.5.1
ENV KIBANA_SHA1 355c631b77c529d3dea304d7f084e658f5cc3123

RUN set -x \
	&& curl -fSL "https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" -o kibana.tar.gz \
	&& echo "${KIBANA_SHA1}  kibana.tar.gz" | sha1sum -c - \
	&& mkdir -p /opt/kibana \
	&& tar -xz --strip-components=1 -C /opt/kibana -f kibana.tar.gz \
	&& rm kibana.tar.gz

ENV PATH /opt/kibana/bin:$PATH
ENV HOME /opt/kibana

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
