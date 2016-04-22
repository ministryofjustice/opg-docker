.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/jre-8

build:
	build:
        docker build -t "$(image):$(newtag)" .
        docker tag "$(image):$(newtag)" "$(image):latest"
