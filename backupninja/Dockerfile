FROM registry.service.opg.digital/opguk/base:latest

RUN apt-get update && \
    apt-get install -y duplicity && \
    apt-get install -y python-paramiko && \
    apt-get install -y python-gobject-2 && \
    apt-get install -y backupninja

ADD docker/etc /etc
ADD docker/usr /usr
ADD docker/confd /etc/confd
ADD docker/my_init /etc/my_init.d

