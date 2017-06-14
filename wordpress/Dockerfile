FROM registry.service.opg.digital/opguk/php-fpm

RUN apt-get update && apt-get install -y php5-mysql php5-curl libpng12-dev libjpeg-dev && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/* && \
    mkdir -p /data && \
    chown app:app /data

USER app

# Install wordpress
RUN cd /tmp && \
    wget https://en-gb.wordpress.org/latest-en_GB.tar.gz && \
    tar -xf latest-en_GB.tar.gz && \
    mv wordpress/* /data/. && \
    rm -rf wordpress latest-en_GB.tar.gz

# Install wordpress plugins
RUN cd /tmp && \
    git clone git@github.com:ministryofjustice/opg-core-help-guidance-template.git

# Install our custom theme
# Add wordpress configuration templates
ADD docker/confd /etc/confd

USER root

# Remove files included from php-fpm container
RUN rm -rf /app/* && \
    ln -s /data /app/public

ENV OPG_SERVICE wordpress
