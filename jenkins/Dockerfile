FROM registry.service.dsd.io/opguk/jre-8:latest

# 8080  - Webapp
# 50000 - Agents
EXPOSE 8080
EXPOSE 50000

# Jenkins home directory is a volume. Therefore 
# configuration and build history can
# be persisted and survive image upgrades
VOLUME /var/jenkins_home

# Jenkins environment variables.
ENV JENKINS_VERSION 1.609.2
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins-ci.org
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# Update and install dependencies etc etc
RUN apt-get update && \
    apt-get install -y \
    wget \
    python-pip \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libssl-dev \
    build-essential \
    python2.7-dev \
    python3-dev \
    libxslt1-dev \
    libxml2-dev \
    git \
    curl \
    zip \
    ttf-dejavu \
    fontconfig && \
    pip install git+https://github.com/ministryofjustice/semvertag.git && \
    pip install git+https://github.com/ministryofjustice/opg-cotton.git && \
    rm -rf /var/lib/apt/lists/*

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on our fresh new installation.
RUN mkdir -p /usr/share/jenkins/ref

# Use tini as a subreaper in the Docker container 
# to adopt zombie processes.
ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -

# We could use ADD here, but this does not 
# check the Last-Modified header.
# see https://github.com/docker/docker/issues/8331
ENV JENKINS_SHA 59215da16f9f8a781d185dde683c05fcf11450ef
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/jenkins/jenkins.war" | sha1sum -c -

# Installation, startup and config files.
COPY /usr/local/bin/plugins.sh /usr/local/bin/plugins.sh
COPY /usr/local/bin/jenkins.sh /usr/local/bin/jenkins.sh

# Our jubbly customisations.
COPY /usr/share/jenkins/ref /usr/share/jenkins/ref

# Bootstrap commands, and our Jenkins service.
COPY /etc/confd /etc/confd
COPY /etc/service /etc/service

# Plugins, plugins everywhere.
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

# Jenkins is the owner of his own home sir!
RUN chown -R root "$JENKINS_HOME" /usr/share/jenkins/ref

# Set the user and private Docker registry env's.
ENV JENKINS_GITHUB_PUBKEY=
ENV JENKINS_GITHUB_PRIVKEY=
ENV JENKINS_GITHUB_AUTHKEYS=
ENV JENKINS_USER_OPGCORE_APITOKEN=
ENV JENKINS_USER_OPGCORE_PASSWORD=
ENV JENKINS_USER_OPGCORE_PUBKEYS=
ENV JENKINS_USER_TRAINING_APITOKEN=
ENV JENKINS_USER_TRAINING_PASSWORD=
ENV JENKINS_USER_TRAINING_PUBKEYS=
ENV JENKINS_DOCKERCFG_URL=
ENV JENKINS_DOCKERCFG_EMAIL=
ENV JENKINS_DOCKERCFG_USERNAME=
ENV JENKINS_DOCKERCFG_PASSWORD=

ENV DEPLOY_GIT_BRANCH=
ENV APP_GIT_DOWNSTREAM_BRANCH=
ENV APP_DOCKER_SUFFIX=
ENV APP_GIT_BRANCH=

ENV GIT_USERNAME=
ENV GIT_EMAIL_ADDRESS=

