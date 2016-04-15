.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/jre-8

build:
	docker build -t "$(image):$(newtag)" -t "$(image):latest" .
