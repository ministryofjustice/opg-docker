FROM registry.service.opg.digital/opguk/jre-8

#Install tools
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      apparmor \
      apt-transport-https \
      ca-certificates \
      curl \
      docker-ce \
      fontconfig \
      gettext \
      libcurl4-gnutls-dev \
      libexpat1-dev \
      libffi-dev \
      libgmp3-dev \
      libssl-dev \
      libx11-6 \
      libxml2-dev \
      libxslt1-dev \
      libyaml-dev \
      openssl \
      python-dev \
      python2.7-dev \
      python3-dev \
      software-properties-common \
      ttf-dejavu \
      zip && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
        wget -q https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz && \
        tar xzf Python-2.7.14.tgz && \
        cd Python-2.7.14 && \
        ./configure --prefix=/opt/python2.7 && make && make install && \
        cd .. && rm -rf /tmp/Python-2.7.14* && \
    cd /tmp && \
        wget -q https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz && \
        tar xzf Python-3.6.2.tgz && \
        cd Python-3.6.2 && \
        ./configure --prefix=/opt/python3.6 && make && make install && \
        cd .. && rm -rf /tmp/Python-3.6.2* && \
    pip install -U pip && \
    pip install \
      docker-compose virtualenv git+https://github.com/ministryofjustice/semvertag.git

# Copy jenkins
COPY docker/etc/my_init.d /etc/my_init.d
COPY docker/etc/confd /etc/confd
COPY docker/etc/ssh /etc/ssh

ENV JENKINS_HOME /srv/jenkins
EXPOSE 22

# Configure app user
RUN usermod -d "$JENKINS_HOME" -m -s /bin/bash app
RUN adduser app docker

RUN chmod a+x /etc/my_init.d/* && \
    usermod -p '*' app && \
    ln -s /dev/stdout /var/log/auth.log
