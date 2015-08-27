NAME = registry.service.dsd.io/opguk/jenkins
VERSION = 0.0.2
TAG ?= ecs
.PHONY: all build clean test tag_latest release

all: build

build:
	docker build -f docker/Dockerfile-$(TAG) -t $(NAME):$(VERSION)-$(TAG) .

clean:
	@eval `docker-machine env default` ||:
	@docker kill `docker ps -a -q` ||:
	@docker rm -f -v `docker ps -a -q` ||:
	@docker rmi -f `docker images -q` ||:

test:
	env NAME=$(NAME) VERSION=$(VERSION)-$(TAG) ./test/runner.sh

tag_latest:
	docker tag -f $(NAME):$(VERSION)-$(TAG) $(NAME):latest-$(TAG)

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION)-$(TAG); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
