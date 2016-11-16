.PHONY: build

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/jenkins-slave

build:
	docker build -t "$(registryUrl)/$(image)" .
	docker tag -f "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"
