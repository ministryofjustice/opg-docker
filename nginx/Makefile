.PHONY: build test

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/nginx

build:
ifeq ($(dockerVersion),)
	docker build -t "$(registryUrl)/$(image):$(newtag)" -t "$(oldRegistryUrl)/$(image):$(newtag)" .
else
	docker build -t "$(registryUrl)/$(image):$(newtag)" .
	docker tag -f "$(registryUrl)/$(image):$(newtag)" "$(oldRegistryUrl)/$(image):$(newtag)"
endif

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:
	
test:
	env NAME=$(image) VERSION=$(nretag) ./test/runner.sh
