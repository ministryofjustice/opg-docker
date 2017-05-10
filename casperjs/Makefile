.PHONY: build

registryUrl ?= registry.service.opg.digital
image = opguk/casperjs

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
