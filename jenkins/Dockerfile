FROM registry.service.opg.digital/opguk/jre-8

#Install tools
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
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
    apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

#Upgrade the verison of pip and install pip requirements
RUN pip install -U pip && \
    pip install meta-compose  git+https://github.com/ministryofjustice/semvertag.git virtualenv

# Download and install docker-machine and docker compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.1/docker-machine-x86_64 >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

#Download and install terraform
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/0.7.4/terraform_0.7.4_linux_amd64.zip && \
    unzip terraform*.zip && \
    mv terraform /usr/bin/terraform && \
    rm -rf /tmp/terraform*

ENV JENKINS_GROOVY_VERSION=2.4.7

ARG user=app
ARG group=app
ARG uid=1000
ARG gid=1000

#Fix docker GID to sync with underlying ECS so that the user can access the docker socket
RUN groupmod -g 497 docker && adduser app docker

# Download and install docker-machine and docker compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.1/docker-machine-x86_64 >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

ENV JENKINS_HOME /srv/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Jenkins is run with user `app`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN usermod -d "$JENKINS_HOME" -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/users/opgops /usr/share/jenkins/ref/.docker /srv/jenkins/.ssh && \
    chown app /srv/jenkins/.ssh && \
    chmod 0700 /srv/jenkins/.ssh

COPY docker/jenkins $JENKINS_REF
# Bootstrap commands, and our Jenkins service.
COPY docker/etc/confd /etc/confd
COPY docker/etc/service /etc/sv/
RUN ln -s /etc/sv/jenkins /etc/service

ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-1.658}

# ADD jenkins war
ADD http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war /usr/share/jenkins/jenkins.war

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/

COPY docker/usr/local/bin/ /usr/local/bin/

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

# Install the Plugins listed in the plugins.txt file
# This is where your customised plugins go
RUN /usr/local/bin/plugins.sh $JENKINS_REF/plugins.txt

# Install the forked plugins listed in forked-plugins.txt file
RUN wget -i $JENKINS_REF/forked-plugins.txt -P /usr/share/jenkins/ref/plugins

USER root
