.PHONY: build

registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/backupninja

build:
	docker build -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"
