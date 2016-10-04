FROM registry.service.dsd.io/opguk/jenkins-base:latest

ARG user=app
ARG group=app
ARG uid=1000
ARG gid=1000

#Fix docker GID to sync with underlying ECS so that the user can access the docker socket
RUN groupmod -g 497 docker && adduser ${user} docker

ENV JENKINS_HOME /srv/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

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

USER root
