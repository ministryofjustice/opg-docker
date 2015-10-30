.PHONY: build
newtag ?= latest
image = registry.service.opg.digital/opguk/kibana

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"