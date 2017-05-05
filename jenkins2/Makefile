.PHONY: build

registryUrl ?= registry.service.opg.digital

image = opguk/jenkins2

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
