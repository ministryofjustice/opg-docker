FROM registry.service.opg.digital/opguk/base:latest

ENV HOME /root

RUN wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y salt-master && apt-get install -y salt-minion

RUN /bin/echo -e "tcp_keepalive_idle: 300\ntcp_keepalive: True\n" >> /etc/salt/minion

RUN mkdir -p /srv/salt/_libs/base /srv/salt/salt-formulas /srv/pillar

ADD docker/salt/_libs/base /srv/salt/_libs/base
ADD docker/salt/top.sls /srv/salt/top.sls

ADD docker/service/salt-master /etc/sv/salt-master
RUN chmod a+x /etc/sv/salt-master/run
RUN  ln -s /etc/sv/salt-master /etc/service/

ADD docker/service/salt-minion /etc/sv/salt-minion
RUN chmod a+x /etc/sv/salt-minion/run
RUN  ln -s /etc/sv/salt-minion /etc/service/

ADD docker/my_init.d /etc/my_init.d
RUN chmod a+x /etc/my_init.d/*

ADD docker/confd /etc/confd
