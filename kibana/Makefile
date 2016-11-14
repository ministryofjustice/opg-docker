.PHONY: build

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/kibana

build:
ifeq ($(dockerVersion),)
	docker build -t "$(registryUrl)/$(image):$(newtag)" -t "$(oldRegistryUrl)/$(image):$(newtag)" .
else
	docker build -t "$(registryUrl)/$(image):$(newtag)" .
	docker tag -f "$(registryUrl)/$(image):$(newtag)" "$(oldRegistryUrl)/$(image):$(newtag)"
endif
