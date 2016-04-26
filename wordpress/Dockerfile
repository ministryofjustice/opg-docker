FROM registry.service.dsd.io/opguk/php-fpm:latest

RUN apt-get update && apt-get install -y php5-mysql php5-curl libpng12-dev libjpeg-dev && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

# Add wordpress configuration templates
ADD docker/confd /etc/confd

# Remove files included from php-fpm container
RUN rm -rf /app/* && \
    ln -s /data /app/public

USER root

ENV OPG_SERVICE wordpress
