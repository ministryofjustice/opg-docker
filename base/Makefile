.PHONY: build
newtag ?= latest
image = registry.service.dsd.io/opguk/base

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
