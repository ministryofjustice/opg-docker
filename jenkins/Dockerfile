FROM jenkins

#Switch to the root user to configure and run the container
USER root

# Update and install dependencies etc etc
RUN apt-get update && \
    apt-get install -y \
    salt-master \
    salt-minion \
    salt-syndic \
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
    zip && \
    pip install git+https://github.com/ministryofjustice/semvertag.git && \
    pip install git+https://github.com/ministryofjustice/opg-cotton.git

RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 && mv confd-0.10.0-linux-amd64 /usr/bin/confd && chmod 0755 /usr/bin/confd

# Our jubbly customisations.
COPY /usr/share/jenkins/ref /usr/share/jenkins/ref

# Plugins, plugins everywhere.
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

# Bootstrap commands, and our Jenkins service.
COPY /etc/confd /etc/confd
COPY /etc/service /etc/service
COPY /etc/my_init.d /etc/my_init.d
COPY /sbin/my_init /sbin/my_init
RUN ln -s /etc/service/run /etc/my_init.d/99-run

# Jenkins is the owner of his own home sir!
RUN chown -R root "$JENKINS_HOME" /usr/share/jenkins/ref

# This env is not carried over from the jenkins 
# image (for some strange reason)
ENV JENKINS_SLAVE_AGENT_PORT=50000

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

