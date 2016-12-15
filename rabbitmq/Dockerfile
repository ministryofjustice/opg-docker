FROM registry.service.opg.digital/opguk/base

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r rabbitmq && useradd -r -d /var/lib/rabbitmq -m -g rabbitmq rabbitmq

# Add the officially endorsed Erlang debian repository:
# See:
#  - http://www.erlang.org/download.html
#  - https://www.erlang-solutions.com/downloads/download-erlang-otp
RUN wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | apt-key add -
RUN echo 'deb http://packages.erlang-solutions.com/debian wheezy contrib' > /etc/apt/sources.list.d/erlang.list

# get logs to stdout (thanks @dumbbell for pushing this upstream! :D)
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-
# https://github.com/rabbitmq/rabbitmq-server/commit/53af45bf9a162dec849407d114041aad3d84feaf

# http://www.rabbitmq.com/install-debian.html
# "Please note that the word testing in this line refers to the state of our release of RabbitMQ, not any particular Debian distribution."
RUN wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -
RUN echo 'deb http://www.rabbitmq.com/debian/ testing main' > /etc/apt/sources.list.d/rabbitmq.list

ENV RABBITMQ_VERSION 3.*

RUN apt-get update && apt-get install -y rabbitmq-server=$RABBITMQ_VERSION --no-install-recommends && rm -rf /var/lib/apt/lists/*

# /usr/sbin/rabbitmq-server has some irritating behavior, and only exists to "su - rabbitmq /usr/lib/rabbitmq/bin/rabbitmq-server ..."
ENV PATH /usr/lib/rabbitmq/bin:$PATH

VOLUME /var/lib/rabbitmq

# Provide default values for confd
ENV HOME /var/lib/rabbitmq
ENV RABBITMQ_TCP_LISTENERS 5672
ENV RABBITMQ_DEFAULT_VHOST /rabbitmq
ENV RABBITMQ_DEFAULT_USER rabbitmq
ENV RABBITMQ_DEFAULT_PASS rabbitmq
ENV RABBITMQ_SSL true
ENV RABBITMQ_SSL_LISTENERS 5671
ENV RABBITMQ_SSL_CERTFILE '/etc/ssl/cert.pem'
ENV RABBITMQ_SSL_KEYFILE '/etc/ssl/key.pem'
ENV RABBITMQ_SSL_VERIFY verify_none
ENV RABBITMQ_SSL_NOPEER false

ADD docker/confd /etc/confd

ADD docker/service/rabbitmq /etc/sv/rabbitmq
RUN chmod a+x /etc/sv/rabbitmq/run
RUN  ln -s /etc/sv/rabbitmq /etc/service/

ENV OPG_SERVICE rabbitmq
