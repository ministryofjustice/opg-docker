FROM registry.service.opg.digital/opguk/php-fpm:0.1.68

RUN apt-get update && apt-get install -y php5-mysql php5-curl libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* 

# Add wordpress configuration templates
ADD docker/confd /etc/confd

# Remove files included from php-fpm container
RUN rm -rf /app/*

# Symlink webroot to mounted data volume
RUN ln -s /data /app/public

USER root

ENV OPG_SERVICE wordpress
