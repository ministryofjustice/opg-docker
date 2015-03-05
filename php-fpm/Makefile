.PHONY: build
newtag ?= latest
image = opguk/php-fpm

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
