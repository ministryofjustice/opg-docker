FROM registry.service.opg.digital/opguk/nginx:latest

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y php5-fpm php5-cli && \
     apt-get install -y php5-xdebug php5-xhprof php5-mcrypt && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

RUN  rm -f /etc/php5/fpm/php-fpm.conf /etc/php5/fpm/pool.d/www.conf /etc/cron.d/php5 && \
     mkdir -p /data/session

ADD  docker/confd /etc/confd

ADD  docker/service/php-fpm /etc/sv/php-fpm
RUN  chmod a+x /etc/sv/php-fpm/run && \
     ln -s /etc/sv/php-fpm /etc/service/

RUN  echo "<?php phpinfo(); ?>" > /app/public/index.php && \
     chown app /app/public/index.php

ADD  docker/logrotate.d/app /etc/logrotate.d/app

ADD  docker/php/* /etc/php5/

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

ADD  docker/scripts/xhprof/profiler /scripts/php-fpm/xhprof/profiler
RUN  chmod -R a+x /scripts/php-fpm

# disable php5-xdebug by default
RUN  rm -f /etc/php5/fpm/conf.d/*xdebug*
RUN  rm -f /etc/php5/cli/conf.d/*xdebug*
RUN  rm /etc/php5/mods-available/xdebug.ini

ADD  docker/nginx /etc/nginx

RUN  pip install schedule statsd requests
ADD  https://raw.githubusercontent.com/ministryofjustice/php-fpm-stats-collector/master/php-fpm-stats-collector.py /usr/local/bin/
RUN  chmod a+x /usr/local/bin/php-fpm-stats-collector.py

ADD  docker/service/php-fpm-stats /etc/sv/php-fpm-stats
RUN  chmod a+x /etc/sv/php-fpm-stats/run
RUN  ln -s /etc/sv/php-fpm-stats /etc/service/

ENV  OPG_PHP_POOL_CHILDREN_MAX 4
ENV  OPG_PHP_POOL_REQUESTS_MAX 0

ENV  OPG_SERVICE php-fpm

ENV  STATSD_HOST monitoring
ENV  STATSD_PORT 8125
ENV  STATSD_DELAY 10
ENV  FPM_STATUS_URL http://localhost:81/status
