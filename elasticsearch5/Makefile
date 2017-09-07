.PHONY: build

registryUrl ?= registry.service.opg.digital
image = opguk/elasticsearch5

build:
	docker build --pull -t "$(registryUrl)/$(image)" .
	docker tag  "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
