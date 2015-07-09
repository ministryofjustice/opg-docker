FROM registry.service.dsd.io/opguk/php-fpm:latest

RUN apt-get update && apt-get install -y openssl php5-mysql php5-curl libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* 

ADD docker/confd /etc/confd

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

# Override app.conf with one that uses SSL cert
ADD docker/nginx/conf.d /etc/nginx/conf.d

# Remove files included from php-fpm container
RUN rm -rf /app/*

# Symlink webroot to mounted data volume
RUN ln -s /data /app/public

USER root
EXPOSE 443
