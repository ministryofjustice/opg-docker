.PHONY: build
newtag ?= latest
image = opguk/monitoring

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
