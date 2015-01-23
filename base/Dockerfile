FROM phusion/baseimage:0.9.15

# Set correct HOME
ENV HOME /root

# For debconf not to complain
ENV DEBIAN_FRONTEND noninteractive

# Ensure that all packages are latest
RUN apt-get update
RUN apt-get -y upgrade

# locale
RUN locale-gen en_GB en_GB.UTF-8

# let's disable ssh access
RUN rm /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN rm -Rf /etc/service/sshd

# our base layout
RUN  apt-get update
RUN  apt-get install -y git
RUN  apt-get install -y joe

#application user and location
RUN  useradd -m -d /app app
RUN  mkdir -p /var/log/app && chown app /var/log/app
RUN  mkdir -p /data && chown app /data
RUN  mkdir -p /var/run/app && chown app /var/run/app
