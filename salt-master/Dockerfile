FROM registry.service.dsd.io/opguk/base:latest

ENV HOME /root

RUN wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y salt-master && apt-get install -y salt-minion

ADD docker/service/salt-master /etc/service/salt-master
RUN chmod a+x /etc/service/salt-master/run

ADD docker/service/salt-minion /etc/service/salt-minion
RUN chmod a+x /etc/service/salt-minion/run

ADD docker/my_init.d /etc/my_init.d
RUN chmod a+x /etc/my_init.d/*

ADD docker/confd /etc/confd
