FROM registry.service.opg.digital/opguk/php-fpm

ADD  docker/phpunit-4.8.35.phar /usr/local/bin/phpunit
RUN chmod +x /usr/local/bin/phpunit

RUN apt-get install php5-mcrypt
RUN php5enmod mcrypt

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]