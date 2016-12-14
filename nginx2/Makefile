.PHONY: build test

registryUrl ?= registry.service.opg.digital
oldRegistryUrl ?= registry.service.dsd.io

image = opguk/nginx

build:
	docker build -t "$(registryUrl)/$(image)" .
	docker tag -f "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image)"
	docker tag -f "$(registryUrl)/$(image)" "$(oldRegistryUrl)/$(image):$(newtag)"

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:
	
test:
	env NAME=$(image) VERSION=$(nretag) ./test/runner.sh
