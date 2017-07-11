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
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.60.1}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=34fde424dde0e050738f5ad1e316d54f741c237bd380bd663a07f96147bb1390

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

# Required minimum plugins. Ecexute the following code in jenkins script console for the list.
#  Jenkins.instance.pluginManager.plugins.sort { it.getDisplayName() }.each{
#    plugin -> println ("${plugin.getShortName()}:${plugin.getVersion()} \\") }
#
RUN /usr/local/bin/install-plugins.sh \
  ace-editor:1.1 \
  ansicolor:0.5.0 \
  ant:1.5 \
  antisamy-markup-formatter:1.5 \
  authentication-tokens:1.3 \
  bouncycastle-api:2.16.1 \
  branch-api:2.0.9 \
  cloudbees-folder:6.0.4 \
  config-file-provider:2.16.0 \
  confluence-publisher:1.8 \
  credentials-binding:1.11 \
  credentials:2.1.13 \
  display-url-api:2.0 \
  docker-commons:1.6 \
  docker-workflow:1.11 \
  durable-task:1.13 \
  envinject:2.1 \
  external-monitor-job:1.7 \
  git-client:2.4.6 \
  git-server:1.7 \
  git:3.3.0 \
  github-api:1.85 \
  github-branch-source:2.0.5 \
  github-oauth:0.27 \
  github:1.27.0 \
  groovy:2.0 \
  handlebars:1.1.1 \
  icon-shim:2.0.3 \
  javadoc:1.4 \
  job-dsl:1.63 \
  jquery-detached:1.2.1 \
  junit:1.20 \
  ldap:1.16 \
  mailer:1.20 \
  matrix-auth:1.6 \
  matrix-project:1.11 \
  momentjs:1.1.1 \
  pam-auth:1.3 \
  pipeline-build-step:2.5 \
  pipeline-graph-analysis:1.3 \
  pipeline-input-step:2.7 \
  pipeline-milestone-step:1.3.1 \
  pipeline-model-api:1.1.4 \
  pipeline-model-declarative-agent:1.1.1 \
  pipeline-model-definition:1.1.4 \
  pipeline-model-extensions:1.1.4 \
  pipeline-multibranch-defaults:1.1 \
  pipeline-rest-api:2.8 \
  pipeline-stage-step:2.2 \
  pipeline-stage-tags-metadata:1.1.4 \
  pipeline-stage-view:2.8 \
  plain-credentials:1.4 \
  role-strategy:2.4.0 \
  scm-api:2.1.1 \
  script-security:1.27 \
  ssh-credentials:1.13 \
  ssh-slaves:1.17 \
  structs:1.7 \
  token-macro:2.1 \
  windows-slaves:1.3.1 \
  workflow-aggregator:2.5 \
  workflow-api:2.16 \
  workflow-basic-steps:2.5 \
  workflow-cps-global-lib:2.8 \
  workflow-cps:2.33 \
  workflow-durable-task-step:2.11 \
  workflow-job:2.11 \
  workflow-multibranch:2.13 \
  workflow-scm-step:2.4 \
  workflow-step-api:2.10 \
  workflow-support:2.14

# Default java options for running jenkins
ENV JAVA_OPTS -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dorg.apache.commons.jelly.tags.fmt.timeZone=Europe/London -Duser.timezone=Europe/London -Duser.country=GB

USER root
