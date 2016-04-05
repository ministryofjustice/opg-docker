.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = ${registryUrl}/opguk/nginx-redirect

build:
	docker build -t "${image}:latest" .
	docker tag "${image}:latest" "${image}:${newtag}"
