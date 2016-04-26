FROM registry.service.dsd.io/opguk/base:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG TERM=linux

RUN apt-get update && \
    apt-get install -y git-core && \
    apt-get install -y curl && \
    apt-get install -y libfreetype6 && \
    apt-get install -y libfontconfig && \
    apt-get install -y python && \
    apt-get install -y php5-cli && \
    apt-get install -y php5-imap && \
    php5enmod imap

RUN curl -LO https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 && \
    tar xjfv phantomjs-1.9.7-linux-x86_64.tar.bz2 -C /usr/local/ && \
    ln -sf /usr/local/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    rm -f phantomjs-1.9.7-linux-x86_64.tar.bz2

RUN git clone https://github.com/n1k0/casperjs.git /usr/local/casperjs && \
    ln -sf /usr/local/casperjs/bin/casperjs /usr/local/bin/casperjs
