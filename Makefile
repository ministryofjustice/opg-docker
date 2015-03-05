.PHONY: build push pull

currenttag = $(shell semvertag latest)
newtag = $(shell semvertag bump patch)

containers = base nginx php-fpm monitoring

build:
	semvertag tag ${newtag}
	$(MAKE) -C base newtag=${newtag}
	$(MAKE) -C nginx newtag=${newtag}
	$(MAKE) -C php-fpm newtag=${newtag}
	$(MAKE) -C monitoring newtag=${newtag}

push:
	docker push opguk/base
	docker push opguk/nginx
	docker push opguk/php-fpm
	docker push opguk/monitoring

pull:
	docker pull opguk/base
	docker pull opguk/nginx
	docker pull opguk/php-fpm
	docker pull opguk/monitoring
