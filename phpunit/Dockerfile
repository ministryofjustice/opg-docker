FROM registry.service.opg.digital/opguk/php-fpm

WORKDIR /tmp

ADD  docker/phpunit-4.8.35.phar phpunit-4.8.35.phar

RUN chmod +x phpunit-4.8.35.phar
RUN mv phpunit-4.8.35.phar /usr/local/bin/phpunit

RUN apt-get install php5-mcrypt
RUN php5enmod mcrypt

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]