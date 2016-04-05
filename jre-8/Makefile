.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = ${registryUrl}/opguk/jre-8

build:
	docker build -t "${image}:latest" .
	docker tag "${image}:latest" "${image}:${newtag}"
