FROM opguk/nginx:latest

RUN  apt-get install -y php5-fpm

RUN  rm -f /etc/php5/fpm/php-fpm.conf
RUN  rm /etc/php5/fpm/pool.d/www.conf

RUN  mkdir -p /data/session

ADD  docker/fpm /etc/php5/fpm
ADD  docker/nginx /etc/nginx

ADD  docker/service/php-fpm /etc/service/php-fpm
RUN  chmod a+x /etc/service/php-fpm/run


RUN  echo "<?php phpinfo(); ?>" > /app/public/index.php
RUN  chown app /app/public/index.php
