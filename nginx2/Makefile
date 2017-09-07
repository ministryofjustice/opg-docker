.PHONY: build test

registryUrl ?= registry.service.opg.digital
image = opguk/nginx2

build:
	docker build --pull -t "$(registryUrl)/$(image)" .
	docker tag  "$(registryUrl)/$(image)" "$(registryUrl)/$(image):$(newtag)"

push:
	docker push  "$(registryUrl)/$(image)"
	docker push "$(registryUrl)/$(image):$(newtag)"

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:

test:
	env NAME=$(image) VERSION=$(nretag) ./test/runner.sh
