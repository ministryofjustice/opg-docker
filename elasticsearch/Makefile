.PHONY: build
newtag ?= latest
image = registry.service.opg.digital/opguk/elasticsearch

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
