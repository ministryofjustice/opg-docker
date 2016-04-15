.PHONY: build test
newtag ?= latest
registryUrl ?= registry.service.opg.digital
image = $(registryUrl)/opguk/nginx

build:
	docker build -t "$(image):$(newtag)" -t "$(image):latest" .

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:
	
test:
	env NAME=$(image) VERSION=$(nretag) ./test/runner.sh
