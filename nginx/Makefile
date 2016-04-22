.PHONY: build test
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/nginx

build:
ifeq ($(dockerVersion),)
	docker build -t "$(image):$(newtag)" -t "$(image):latest" .
else
	docker build -t "$(image):$(newtag)" .
	docker tag -f "$(image):$(newtag)" "$(image):latest"
endif

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:
	
test:
	env NAME=$(image) VERSION=$(nretag) ./test/runner.sh
