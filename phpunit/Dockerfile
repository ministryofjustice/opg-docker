FROM registry.service.opg.digital/opguk/php-fpm

ADD  docker/phpunit-4.8.36.phar /usr/local/bin/phpunit

RUN php5enmod mcrypt

# enable php5-xdebug for code coverage
RUN cp /etc/php5/xdebug-enable.ini /etc/php5/fpm/conf.d/20-xdebug.ini
RUN cp /etc/php5/xdebug-enable.ini /etc/php5/cli/conf.d/20-xdebug.ini

RUN apt-get update && apt-get install -y \
    php5-curl php5-dev php-pear

RUN apt-get install -y pkg-config

RUN pecl install mongodb-1.2.9 && \
    echo "extension=mongodb.so" > /etc/php5/mods-available/mongodb.ini && \
    php5enmod mongodb

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]