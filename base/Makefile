.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = ${registryUrl}/opguk/base

build:
	docker build -t "${image}:${newtag}" -t "${image}:latest" .
	docker tag "${image}:latest" "${image}:${newtag}"
