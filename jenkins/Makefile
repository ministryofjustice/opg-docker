.PHONY: build
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = ${registryUrl}/opguk/jenkins

build:
	docker build -t "${image}:${newtag}" -t "${image}:latest" .