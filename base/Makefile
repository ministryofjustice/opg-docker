.PHONY: build

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/base

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"
