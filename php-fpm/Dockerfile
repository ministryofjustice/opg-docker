FROM opguk/nginx:latest

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y php5-fpm php5-cli && \
     apt-get autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}/ && rm -rf /tmp/* /var/tmp/*

RUN  rm -f /etc/php5/fpm/php-fpm.conf
RUN  rm /etc/php5/fpm/pool.d/www.conf

RUN  mkdir -p /data/session

ADD  docker/fpm /etc/php5/fpm
ADD  docker/nginx /etc/nginx

ADD  docker/service/php-fpm /etc/service/php-fpm
RUN  chmod a+x /etc/service/php-fpm/run

ADD  docker/update-php-fpm-environment.sh /sbin/update-php-fpm-environment.sh
RUN  chmod a+x /sbin/update-php-fpm-environment.sh

RUN  echo "<?php phpinfo(); ?>" > /app/public/index.php
RUN  chown app /app/public/index.php

ADD  docker/beaver.d /etc/beaver.d

