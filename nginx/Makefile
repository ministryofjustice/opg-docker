.PHONY: build
newtag ?= latest
image = opguk/nginx

build:
	docker build -t "${image}:latest" .
	docker tag -f "${image}:latest" "${image}:${newtag}"
