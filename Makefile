.PHONY: build push pull

currenttag = $(shell semvertag latest)
newtag = $(shell semvertag bump patch)
registry = registry.service.opg.digital
containers = base nginx php-fpm golang rabbitmq wordpress jre-8 elasticsearch kibana nginx-router

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
	$(MAKE) -C kibana newtag=${newtag}
	$(MAKE) -C nginx-router newtag=${newtag}

push:
	docker push ${registry}/opguk/base:${currenttag}
	docker push ${registry}/opguk/base:latest
	docker push ${registry}/opguk/nginx:${currenttag}
	docker push ${registry}/opguk/nginx:latest
	docker push ${registry}/opguk/php-fpm:${currenttag}
	docker push ${registry}/opguk/php-fpm:latest
	docker push ${registry}/opguk/golang:${currenttag}
	docker push ${registry}/opguk/golang:latest
	docker push ${registry}/opguk/rabbitmq:${currenttag}
	docker push ${registry}/opguk/rabbitmq:latest
	docker push ${registry}/opguk/wordpress:${currenttag}
	docker push ${registry}/opguk/wordpress:latest
	docker push ${registry}/opguk/jre-8:${currenttag}
	docker push ${registry}/opguk/jre-8:latest
	docker push ${registry}/opguk/elasticsearch:${currenttag}
	docker push ${registry}/opguk/elasticsearch:latest
	docker push ${registry}/opguk/kibana:${currenttag}
	docker push ${registry}/opguk/kibana:latest
	docker push ${registry}/opguk/nginx-router:${currenttag}
	docker push ${registry}/opguk/nginx-router:latest

pull:
	docker pull ${registry}/opguk/base
	docker pull ${registry}/opguk/nginx
	docker pull ${registry}/opguk/php-fpm
	docker pull ${registry}/opguk/golang
	docker pull ${registry}/opguk/rabbitmq
	docker pull ${registry}/opguk/wordpress
	docker pull ${registry}/opguk/jre-8
	docker pull ${registry}/opguk/elasticsearch
	docker pull ${registry}/opguk/kibana
	docker pull ${registry}/opguk/nginx-router
