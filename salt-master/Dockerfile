FROM registry.service.opg.digital/opguk/base:latest

ENV HOME /root

RUN wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
    echo "deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y salt-master && apt-get install -y salt-minion && \
    /bin/echo -e "tcp_keepalive_idle: 300\ntcp_keepalive: True\n" >> /etc/salt/minion && \

ADD docker/salt/ /srv/salt/

ADD docker/service/salt-master /etc/sv/salt-master
RUN chmod a+x /etc/sv/salt-master/run && \
    ln -s /etc/sv/salt-master /etc/service/

ADD docker/service/salt-minion /etc/sv/salt-minion
RUN chmod a+x /etc/sv/salt-minion/run && \
    ln -s /etc/sv/salt-minion /etc/service/

ADD docker/my_init.d /etc/my_init.d
RUN chmod a+x /etc/my_init.d/*

ADD docker/confd /etc/confd
