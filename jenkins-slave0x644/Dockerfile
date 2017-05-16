FROM registry.service.opg.digital/opguk/jre-80x644

#Install tools
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt update && \
    apt upgrade -y && \
    apt install -y \
    apparmor \
    docker-ce \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libssl-dev \
    python2.7-dev \
    python3-dev \
    python-dev \
    libxslt1-dev \
    libxml2-dev \
    zip \
    ttf-dejavu \
    fontconfig \
    libyaml-dev \
    libgmp3-dev \
    libffi-dev \
    libssl-dev && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

# Install pip requirements
RUN pip install meta-compose git+https://github.com/ministryofjustice/semvertag.git virtualenv

#Fix docker GID to sync with underlying ECS so that the user can access the docker socket
RUN groupmod -g 497 docker && adduser app docker

ENV JENKINS_HOME /srv/jenkins

# Jenkins is run with user `app`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN usermod -d "$JENKINS_HOME" -m -s /bin/bash app

ADD  docker/etc/my_init.d /etc/my_init.d

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.

RUN mkdir -p /usr/share/jenkins/ref/{users/opgops, .docker} && \
    mkdir -p /srv/jenkins/builds && \
    mkdir -p /srv/jenkins/.ssh && \
    chown app /srv/jenkins/.ssh && \
    chown app /srv/jenkins/builds && \
    chmod 0700 /srv/jenkins/.ssh && \
    chmod a+x /etc/my_init.d/* && \
    usermod -p '*' app && \
    ln -s /dev/stdout /var/log/auth.log

COPY docker/etc/confd /etc/confd
COPY docker/etc/ssh /etc/ssh

EXPOSE 22
ENV OPG_SERVICE "jenkins-slave"
