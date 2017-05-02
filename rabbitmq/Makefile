.PHONY: build test

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/rabbitmq

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"

test:
	env NAME=$(image) VERSION=$(newtag) RABBITMQ_SSL=true ./test