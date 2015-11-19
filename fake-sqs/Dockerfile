FROM registry.service.dsd.io/opguk/base:latest

# Set correct HOME
ENV HOME /root

# Install ruby
RUN apt-get update && apt-get -y install ruby && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

# Gem install
RUN gem install fake_sqs

# Start up scripts
ADD docker/service/fake_sqs /etc/service/fake_sqs
RUN chmod a+x /etc/service/fake_sqs/run

ADD docker/my_init.d /etc/my_init.d
RUN chmod a+x /etc/my_init.d/*

# Expose port
EXPOSE 4568

# Directory
RUN mkdir -p /var/lib/sqs

# Service tag
ENV OPG_SERVICE fake_sqs
