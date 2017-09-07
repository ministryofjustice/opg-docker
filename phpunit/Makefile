.PHONY: build

registryUrl ?= registry.service.opg.digital
image = opguk/phpunit

build:
	docker build --pull $(no-cache) -t "$(registryUrl)/$(image)" .
	docker tag -f "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
