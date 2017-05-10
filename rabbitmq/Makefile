.PHONY: build test

registryUrl ?= registry.service.opg.digital
image = opguk/rabbitmq

build:
	docker build $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"

test:
	env NAME=$(image) VERSION=$(newtag) RABBITMQ_SSL=true ./test
