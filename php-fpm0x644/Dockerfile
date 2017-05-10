FROM registry.service.opg.digital/opguk/nginx0x644

ARG PHP_PACKAGES="php-fpm php-cli php-imagick php-mongodb mongodb-clients php-curl php7.0-xml postgresql-client php-pgsql php-mcrypt"

RUN apt install -y $PHP_PACKAGES && \
    apt clean && apt -y autoremove && \
    rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

RUN rm -f /etc/php/7.0/fpm/php-fpm.conf /etc/php/7.0fpm/pool.d/www.conf /etc/cron.d/php && \
    mkdir -p /data/session

ADD  docker/confd /etc/confd

ADD  docker/service/php-fpm /etc/sv/php-fpm
RUN  chmod a+x /etc/sv/php-fpm/run && \
     ln -s /etc/sv/php-fpm /etc/service/

RUN  echo "<?php echo('hello World :)') ?>" > /app/public/index.php && \
     chown app /app/public/index.php

ADD  docker/logrotate.d/app /etc/logrotate.d/app

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

ADD  docker/nginx /etc/nginx

RUN  pip install schedule statsd requests && \
     curl -s https://raw.githubusercontent.com/ministryofjustice/php-fpm-stats-collector/master/php-fpm-stats-collector.py > /usr/local/bin/php-fpm-stats-collector.py && \
     chmod a+x /usr/local/bin/php-fpm-stats-collector.py

ADD  docker/service/php-fpm-stats /etc/sv/php-fpm-stats
RUN  chmod a+x /etc/sv/php-fpm-stats/run && ln -s /etc/sv/php-fpm-stats /etc/service/

ENV  OPG_PHP_POOL_CHILDREN_MAX 4
ENV  OPG_PHP_POOL_REQUESTS_MAX 0

ENV  STATSD_HOST monitoring
ENV  STATSD_PORT 8125
ENV  STATSD_DELAY 10
ENV  FPM_STATUS_URL http://localhost:81/status
