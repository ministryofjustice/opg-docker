.PHONY: build push pull

currenttag = $(shell semvertag latest)
newtag = $(shell semvertag bump patch)

containers = base nginx php-fpm golang rabbitmq wordpress jre-8 elasticsearch

build:
	semvertag tag ${newtag}
	$(MAKE) -C base newtag=${newtag}
	$(MAKE) -C nginx newtag=${newtag}
	$(MAKE) -C php-fpm newtag=${newtag}
	$(MAKE) -C golang newtag=${newtag}
	$(MAKE) -C rabbitmq newtag=${newtag}
	$(MAKE) -C wordpress newtag=${newtag}
	$(MAKE) -C jre-8 newtag=${newtag}
	$(MAKE) -C elasticsearch newtag=${newtag}

push:
	docker push registry.service.dsd.io/opguk/base:${currenttag}
	docker push registry.service.dsd.io/opguk/base:latest
	docker push registry.service.dsd.io/opguk/nginx:${currenttag}
	docker push registry.service.dsd.io/opguk/nginx:latest
	docker push registry.service.dsd.io/opguk/php-fpm:${currenttag}
	docker push registry.service.dsd.io/opguk/php-fpm:latest
	docker push registry.service.dsd.io/opguk/golang:${currenttag}
	docker push registry.service.dsd.io/opguk/golang:latest
	docker push registry.service.dsd.io/opguk/rabbitmq:${currenttag}
	docker push registry.service.dsd.io/opguk/rabbitmq:latest
	docker push registry.service.dsd.io/opguk/wordpress:${currenttag}
	docker push registry.service.dsd.io/opguk/wordpress:latest
	docker push registry.service.dsd.io/opguk/jre-8:${currenttag}
	docker push registry.service.dsd.io/opguk/jre-8:latest
	docker push registry.service.dsd.io/opguk/elasticsearch:${currenttag}
	docker push registry.service.dsd.io/opguk/elasticsearch:latest

pull:
	docker pull registry.service.dsd.io/opguk/base
	docker pull registry.service.dsd.io/opguk/nginx
	docker pull registry.service.dsd.io/opguk/php-fpm
	docker pull registry.service.dsd.io/opguk/golang
	docker pull registry.service.dsd.io/opguk/rabbitmq
	docker pull registry.service.dsd.io/opguk/wordpress
	docker pull registry.service.dsd.io/opguk/jre-8
	docker pull registry.service.dsd.io/opguk/elasticsearch
