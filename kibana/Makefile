.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = ${registryUrl}/opguk/kibana

build:
	docker build -t "${image}:latest" .
	docker tag "${image}:latest" "${image}:${newtag}"