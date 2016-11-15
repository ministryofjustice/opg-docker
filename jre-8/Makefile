.PHONY: build

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/jre-8

build:
	docker build -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"