.PHONY: build

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/golang

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag -f "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"