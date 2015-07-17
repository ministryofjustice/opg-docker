.PHONY: build
newtag ?= latest
image = registry.service.dsd.io/opguk/kibana

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"