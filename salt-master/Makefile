.PHONY: build test

registryUrl ?= registry.service.opg.digital
image = opguk/salt-master

build:
	docker build --pull $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
