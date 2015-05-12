FROM registry.service.dsd.io/opguk/base:latest

RUN  echo "deb http://packages.elasticsearch.org/logstash/1.4/debian stable main" > /etc/apt/sources.list.d/logstash.list
RUN  curl -s http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y logstash logstash-contrib && \
     apt-get install -y redis-server && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*


ADD  docker/redis /etc/redis

ADD  docker/service/redis /etc/service/redis
RUN  chmod a+x /etc/service/redis/run

ADD  docker/service/logstash /etc/service/logstash
RUN  chmod a+x /etc/service/logstash/run

ADD  docker/service/kibana /etc/service/kibana
RUN  chmod a+x /etc/service/kibana/run

ADD docker/logstash /etc/logstash

EXPOSE 80 9200 6379 514
