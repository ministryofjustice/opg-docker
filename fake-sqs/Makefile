.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/fake-sqs

build:
        docker build -t "$(image):$(newtag)" .
        docker tag "$(image):$(newtag)" "$(image):latest"
