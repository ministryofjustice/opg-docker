.PHONY: build test

registryUrl ?= registry.service.opg.digital

image = opguk/nginx0x644

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
