FROM registry.service.dsd.io/opguk/jre-8:latest

#Install tools
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    wget \
    apparmor \
    docker-engine=1.9.1-0~trusty \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libssl-dev \
    build-essential \
    python2.7-dev \
    python3-dev \
    libxslt1-dev \
    libxml2-dev \
    curl \
    zip \
    ttf-dejavu \
    fontconfig \
    libyaml-dev \
    libgmp3-dev && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* && rm -rf /var/lib/apt/lists/*

#Upgrade the verison of pip and install pip requirements
RUN pip install -U pip && \
    pip install meta-compose  git+https://github.com/ministryofjustice/semvertag.git virtualenv

# Download and install docker-machine and docker compose
RUN curl -L https://github.com/docker/machine/releases/download/v0.8.1/docker-machine-x86_64 >/usr/local/bin/docker-machine && \
  chmod +x /usr/local/bin/docker-machine

#Download and install terraform
RUN cd /tmp && \
    pwd && \
    wget https://releases.hashicorp.com/terraform/0.7.4/terraform_0.7.4_linux_amd64.zip && \
    unzip terraform*.zip && \
    mkdir -p /opt/terraform && \
    mv /tmp/terraform/*.* /opt/terraform/. && \
    rm -rf /tmp/terraform* && \
    echo "PATH=:/opt/terraform/" > /etc/environment

ARG user=app
ARG group=app
ARG uid=1000
ARG gid=1000

#Fix docker GID to sync with underlying ECS so that the user can access the docker socket
RUN groupmod -g 497 docker && adduser app docker
