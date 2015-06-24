.PHONY: build push pull

currenttag = $(shell semvertag latest)
newtag = $(shell semvertag bump patch)

containers = base nginx php-fpm

build:
	semvertag tag ${newtag}
	$(MAKE) -C base newtag=${newtag}
	$(MAKE) -C nginx newtag=${newtag}
	$(MAKE) -C php-fpm newtag=${newtag}

push:
	docker push registry.service.dsd.io/opguk/base:${currenttag}
	docker push registry.service.dsd.io/opguk/base:latest
	docker push registry.service.dsd.io/opguk/nginx:${currenttag}
	docker push registry.service.dsd.io/opguk/nginx:latest
	docker push registry.service.dsd.io/opguk/php-fpm:${currenttag}
	docker push registry.service.dsd.io/opguk/php-fpm:latest

pull:
	docker pull registry.service.dsd.io/opguk/base
	docker pull registry.service.dsd.io/opguk/nginx
	docker pull registry.service.dsd.io/opguk/php-fpm
