.PHONY: build
newtag ?= latest
image = registry.service.dsd.io/opguk/jenkins-ecs

build:
	docker build -t "${image}:moj-latest" .
	docker tag -f "${image}:moj-latest" "${image}:moj-${newtag}"
	