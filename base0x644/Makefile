.PHONY: build

registryUrl ?= registry.service.opg.digital

image = opguk/base0x644

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
