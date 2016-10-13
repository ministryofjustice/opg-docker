FROM registry.service.dsd.io/opguk/jre-8:latest

#Install tools
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    apparmor \
    docker-engine=1.9.1-0~trusty \
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

# Download and install docker-machine and docker compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.1/docker-machine-x86_64 >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine

#Download and install terraform
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/0.7.4/terraform_0.7.4_linux_amd64.zip && \
    unzip terraform*.zip && \
    mv terraform /usr/bin/terraform && \
    rm -rf /tmp/terraform*

ARG user=app
ARG group=app
ARG uid=1000
ARG gid=1000

# Download and install docker-machine and docker compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.1/docker-machine-x86_64 >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

#Fix docker GID to sync with underlying ECS so that the user can access the docker socket
RUN groupmod -g 497 docker && adduser app docker

ENV JENKINS_HOME /srv/jenkins

# Jenkins is run with user `app`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN usermod -d "$JENKINS_HOME" -m -s /bin/bash ${user}

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
