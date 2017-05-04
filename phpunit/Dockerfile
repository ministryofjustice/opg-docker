FROM registry.service.opg.digital/opguk/php-fpm

ADD  docker/phpunit-4.8.35.phar /usr/local/bin/phpunit

RUN php5enmod mcrypt

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]