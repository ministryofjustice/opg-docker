NAME = registry.service.dsd.io/opguk/jenkins
VERSION = 0.0.1
TAG ?= ecs
.PHONY: all build test tag_latest release ssh

all: build

build:
	docker build -f Dockerfile-$(TAG) -t $(NAME):$(VERSION)-$(TAG) .

test:
	env NAME=$(NAME) VERSION=$(VERSION)-$(TAG) ./test/runner.sh

tag_latest:
	docker tag -f $(NAME):$(VERSION)-$(TAG) $(NAME):latest-$(TAG)

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION)-$(TAG); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
