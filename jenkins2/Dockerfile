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
    pip install virtualenv git+https://github.com/ministryofjustice/semvertag.git && \
    curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) \
         -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose



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
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.121.1}

# jenkins.war sha256sum checksum, download will be validated using it
ARG JENKINS_SHA=5bb075b81a3929ceada4e960049e37df5f15a1e3cfc9dc24d749858e70b48919

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
# Remove the trailing backslash after the last plugin output
# def plugins = Jenkins.instance.pluginManager.plugins;
# plugins = plugins.sort(false)
# plugins.each{
#    plugin -> println ("${plugin.getShortName()}:${plugin.getVersion()} \\") }

RUN /usr/local/bin/install-plugins.sh \
ace-editor:1.1 \
analysis-core:1.95 \
ansicolor:0.5.2 \
ant:1.8 \
antisamy-markup-formatter:1.5 \
apache-httpcomponents-client-4-api:4.5.5-3.0 \
authentication-tokens:1.3 \
aws-credentials:1.23 \
aws-java-sdk:1.11.341 \
blueocean:1.6.1 \
blueocean-autofavorite:1.2.2 \
blueocean-bitbucket-pipeline:1.6.1 \
blueocean-commons:1.6.1 \
blueocean-config:1.6.1 \
blueocean-core-js:1.6.1 \
blueocean-dashboard:1.6.1 \
blueocean-display-url:2.2.0 \
blueocean-events:1.6.1 \
blueocean-git-pipeline:1.6.1 \
blueocean-github-pipeline:1.6.1 \
blueocean-i18n:1.6.1 \
blueocean-jira:1.6.1 \
blueocean-jwt:1.6.1 \
blueocean-personalization:1.6.1 \
blueocean-pipeline-api-impl:1.6.1 \
blueocean-pipeline-editor:1.6.1 \
blueocean-pipeline-scm-api:1.6.1 \
blueocean-rest:1.6.1 \
blueocean-rest-impl:1.6.1 \
blueocean-web:1.6.1 \
bouncycastle-api:2.16.3 \
branch-api:2.0.20 \
checkstyle:3.50 \
cloudbees-bitbucket-branch-source:2.2.11 \
cloudbees-folder:6.5.1 \
clover:4.9.0 \
command-launcher:1.2 \
config-file-provider:2.18 \
confluence-publisher:2.0.1 \
copyartifact:1.39.1 \
credentials:2.1.17 \
credentials-binding:1.16 \
custom-tools-plugin:0.5 \
display-url-api:2.2.0 \
docker-build-step:2.0 \
docker-commons:1.13 \
docker-workflow:1.17 \
durable-task:1.22 \
ec2:1.39 \
envinject:2.1.5 \
envinject-api:1.5 \
extended-choice-parameter:0.76 \
external-monitor-job:1.7 \
favorite:2.3.2 \
file-operations:1.7 \
git:3.9.1 \
git-client:2.7.2 \
git-server:1.7 \
github:1.29.2 \
github-api:1.92 \
github-branch-source:2.3.6 \
github-oauth:0.29 \
groovy:2.0 \
handlebars:1.1.1 \
handy-uri-templates-2-api:2.1.6-1.0 \
htmlpublisher:1.16 \
icon-shim:2.0.3 \
jackson2-api:2.8.11.3 \
javadoc:1.4 \
jdk-tool:1.1 \
jenkins-design-language:1.6.1 \
jira:3.0.0 \
job-dsl:1.69 \
jquery:1.12.4-0 \
jquery-detached:1.2.1 \
jsch:0.1.54.2 \
junit:1.24 \
ldap:1.20 \
lockable-resources:2.2 \
mailer:1.21 \
matrix-auth:2.2 \
matrix-project:1.13 \
maven-plugin:3.1.2 \
mercurial:2.3 \
momentjs:1.1.1 \
node-iterator-api:1.5.0 \
pam-auth:1.3 \
pipeline-build-step:2.7 \
pipeline-graph-analysis:1.7 \
pipeline-input-step:2.8 \
pipeline-milestone-step:1.3.1 \
pipeline-model-api:1.3 \
pipeline-model-declarative-agent:1.1.1 \
pipeline-model-definition:1.3 \
pipeline-model-extensions:1.3 \
pipeline-multibranch-defaults:1.1 \
pipeline-rest-api:2.10 \
pipeline-stage-step:2.3 \
pipeline-stage-tags-metadata:1.3 \
pipeline-stage-view:2.10 \
plain-credentials:1.4 \
pubsub-light:1.12 \
purge-build-queue-plugin:1.0 \
resource-disposer:0.10 \
role-strategy:2.8.1 \
scm-api:2.2.7 \
script-security:1.44 \
slack:2.3 \
slave-setup:1.10 \
sse-gateway:1.15 \
ssh-credentials:1.14 \
ssh-slaves:1.26 \
structs:1.14 \
timestamper:1.8.10 \
token-macro:2.5 \
variant:1.1 \
windows-slaves:1.3.1 \
workflow-aggregator:2.5 \
workflow-api:2.27 \
workflow-basic-steps:2.8 \
workflow-cps:2.54 \
workflow-cps-global-lib:2.9 \
workflow-durable-task-step:2.19 \
workflow-job:2.21 \
workflow-multibranch:2.19 \
workflow-scm-step:2.6 \
workflow-step-api:2.16 \
workflow-support:2.19 \
ws-cleanup:0.34

# Default java options for running jenkins
ENV JAVA_OPTS -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dorg.apache.commons.jelly.tags.fmt.timeZone=Europe/London -Duser.timezone=Europe/London -Duser.country=GB -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts allow-same-origin;\"

USER root
