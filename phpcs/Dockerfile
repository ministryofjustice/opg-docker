FROM registry.service.opg.digital/opguk/php-fpm

RUN apt-get update && apt-get install -y \
    php-pear

RUN pear install PHP_CodeSniffer

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["/usr/bin/phpcs"]
CMD ["--help"]