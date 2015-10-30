.PHONY: build push
newtag ?= latest
image = registry.service.opg.digital/opguk/base

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
push:
	docker push ${image}:${newtag}
