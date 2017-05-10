.PHONY: build

registryUrl ?= registry.service.opg.digital
image = opguk/jre-8

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
