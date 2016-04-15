.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/nginx-router

build:
	docker build -t "$(image):$(newtag)" -t "$(image):latest" .
