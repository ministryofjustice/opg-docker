FROM registry.service.dsd.io/opguk/backupninja:latest

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" > /etc/apt/sources.list.d/mongodb-org.list && \
    apt-get update && \
    apt-get install -y python-openssl && \
    apt-get install -y mongodb-org=3.0.3

ADD  docker/service/mongod /etc/sv/mongod
RUN  chmod a+x /etc/sv/mongod/run && \
     ln -s /etc/sv/mongod /etc/service/

RUN mkdir -p /data/mongodb

ADD docker/confd /etc/confd
ADD docker/opt /opt
ADD docker/my_init /etc/my_init.d

VOLUME /data/mongodb

EXPOSE 27017
