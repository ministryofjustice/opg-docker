FROM registry.service.opg.digital/opguk/base0x644

ENV MONGODB_VERSION 3.0.15

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" > /etc/apt/sources.list.d/mongodb-org.list && \
    apt update && \
    apt install -y duplicity python-paramiko python-gobject-2 backupninja python-openssl mongodb-org=${MONGODB_VERSION}

ADD docker/etc /etc
ADD docker/usr /usr
ADD docker/confd /etc/confd
ADD docker/opt /opt
ADD docker/my_init /etc/my_init.d

ADD  docker/service/mongod /etc/sv/mongod
RUN  chmod a+x /etc/sv/mongod/run && \
     ln -s /etc/sv/mongod /etc/service/

RUN mkdir -p /data/mongodb

VOLUME /data/mongodb

EXPOSE 27017

ENV OPG_SERVICE "mongodb"
