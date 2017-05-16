.PHONY: build

registryUrl ?= registry.service.opg.digital
image = opguk/elasticsearch50x644

build:
	docker build -t "$(registryUrl)/$(image)" .
	docker tag  "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
