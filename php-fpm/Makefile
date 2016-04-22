.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/php-fpm

build:
        docker build -t "$(image):$(newtag)" .
        docker tag "$(image):$(newtag)" "$(image):latest"
