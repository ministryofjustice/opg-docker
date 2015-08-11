FROM registry.service.dsd.io/opguk/nginx:latest

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y php5-fpm php5-cli && \
     apt-get install -y php5-xdebug php5-xhprof php5-mcrypt && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

RUN  rm -f /etc/php5/fpm/php-fpm.conf
RUN  rm /etc/php5/fpm/pool.d/www.conf

RUN  mkdir -p /data/session

ADD  docker/fpm /etc/php5/fpm
ADD  docker/nginx /etc/nginx

ADD  docker/service/php-fpm /etc/service/php-fpm
RUN  chmod a+x /etc/service/php-fpm/run

RUN  echo "<?php phpinfo(); ?>" > /app/public/index.php
RUN  chown app /app/public/index.php

ADD  docker/logrotate.d/app /etc/logrotate.d/app

ADD  docker/beaver.d /etc/beaver.d

ADD  docker/php/* /etc/php5/

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

RUN mkdir -p /scripts/php-fpm/xhprof
ADD docker/scripts/xhprof/profiler /scripts/php-fpm/xhprof/profiler
RUN chmod -R a+x /scripts/php-fpm

# disable php5-xdebug by default
RUN  rm -f /etc/php5/fpm/conf.d/*xdebug*
RUN  rm -f /etc/php5/cli/conf.d/*xdebug*
RUN  rm /etc/php5/mods-available/xdebug.ini
