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
      libexpat1-dev \
      libffi-dev \
      libgmp3-dev \
      libssl-dev \
      libx11-6 \
      libxml2-dev \
      libxslt1-dev \
      libyaml-dev \
      python-dev \
      python2.7-dev \
      python3-dev \
      software-properties-common \
      ttf-dejavu \
      zip && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/* && \
    pip install -U pip && \
    pip install \
      docker-compose virtualenv git+https://github.com/ministryofjustice/semvertag.git


### This section is from https://github.com/jenkinsci/docker/blob/master/Dockerfile with changes ###

ENV JENKINS_HOME /srv/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

ARG user=app
ARG group=app
ARG uid=1000
ARG gid=1000


# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid.
# Add jenkins user to docker group
RUN groupmod -g ${gid} -n ${group} app && \
    usermod -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash -l ${user} app && \
    adduser ${user} docker

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# Bootstrap commands, and our Jenkins service.
COPY docker/etc/service /etc/sv/
RUN ln -s /etc/sv/jenkins /etc/service


# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.89.3}

# jenkins.war sha256sum checksum, download will be validated using it
ARG JENKINS_SHA=79f176e9388cdeb0deb0e6af49ff9d1ff4b7a3c47102af11e3e9461bf268983a

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

### END ###

# Required minimum plugins. Execute the following code in jenkins script console for the list.
#  Jenkins.instance.pluginManager.plugins.sort { it.getDisplayName() }.each{
#    plugin -> println ("${plugin.getShortName()}:${plugin.getVersion()} \\") }
#
RUN /usr/local/bin/install-plugins.sh \
ace-editor:1.1 \
analysis-core:1.94 \
ansicolor:0.5.2 \
ant:1.8 \
antisamy-markup-formatter:1.5 \
apache-httpcomponents-client-4-api:4.5.3-2.1 \
authentication-tokens:1.3 \
aws-credentials:1.23 \
aws-java-sdk:1.11.264 \
bouncycastle-api:2.16.2 \
branch-api:2.0.18 \
checkstyle:3.50 \
cloudbees-folder:6.3 \
clover:4.8.0 \
config-file-provider:2.17 \
confluence-publisher:2.0.1 \
copyartifact:1.39 \
credentials-binding:1.14 \
credentials:2.1.16 \
custom-tools-plugin:0.5 \
display-url-api:2.2.0 \
docker-build-step:2.0 \
docker-commons:1.11 \
docker-workflow:1.14 \
durable-task:1.17 \
ec2:1.38 \
envinject-api:1.5 \
envinject:2.1.5 \
extended-choice-parameter:0.76 \
external-monitor-job:1.7 \
file-operations:1.7 \
git-client:2.7.1 \
git-server:1.7 \
git:3.7.0 \
github-api:1.90 \
github-branch-source:2.3.2 \
github-oauth:0.29 \
github:1.29.0 \
groovy:2.0 \
handlebars:1.1.1 \
htmlpublisher:1.14 \
icon-shim:2.0.3 \
jackson2-api:2.8.10.1 \
javadoc:1.4 \
job-dsl:1.66 \
jquery-detached:1.2.1 \
jquery:1.12.4-0 \
jsch:0.1.54.1 \
junit:1.23 \
ldap:1.18 \
lockable-resources:2.1 \
mailer:1.20 \
matrix-auth:2.2 \
matrix-project:1.12 \
maven-plugin:3.1 \
momentjs:1.1.1 \
node-iterator-api:1.5.0 \
pam-auth:1.3 \
pipeline-build-step:2.7 \
pipeline-graph-analysis:1.6 \
pipeline-input-step:2.8 \
pipeline-milestone-step:1.3.1 \
pipeline-model-api:1.2.6 \
pipeline-model-declarative-agent:1.1.1 \
pipeline-model-definition:1.2.6 \
pipeline-model-extensions:1.2.6 \
pipeline-multibranch-defaults:1.1 \
pipeline-rest-api:2.9 \
pipeline-stage-step:2.3 \
pipeline-stage-tags-metadata:1.2.6 \
pipeline-stage-view:2.9 \
plain-credentials:1.4 \
purge-build-queue-plugin:1.0 \
role-strategy:2.6.1 \
scm-api:2.2.6 \
script-security:1.40 \
slack:2.3 \
slave-setup:1.10 \
ssh-credentials:1.13 \
ssh-slaves:1.25 \
structs:1.10 \
token-macro:2.3 \
windows-slaves:1.3.1 \
workflow-aggregator:2.5 \
workflow-api:2.25 \
workflow-basic-steps:2.6 \
workflow-cps-global-lib:2.9 \
workflow-cps:2.43 \
workflow-durable-task-step:2.18 \
workflow-job:2.17 \
workflow-multibranch:2.17 \
workflow-scm-step:2.6 \
workflow-step-api:2.14 \
workflow-support:2.17


# Default java options for running jenkins
ENV JAVA_OPTS -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dorg.apache.commons.jelly.tags.fmt.timeZone=Europe/London -Duser.timezone=Europe/London -Duser.country=GB

USER root
