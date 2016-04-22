.PHONY: build test
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/salt-master

build:
        docker build -t "$(image):$(newtag)" .
        docker tag "$(image):$(newtag)" "$(image):latest"
