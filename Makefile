.PHONY: build push pull test

currenttag = $(shell semvertag latest)
newtag = $(shell semvertag bump patch)
registryUrl = registry.service.opg.digital

containers = base nginx php-fpm golang rabbitmq wordpress jre-8 elasticsearch kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect

build:
	semvertag tag ${newtag}
	$(MAKE) -C base newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C nginx newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C php-fpm newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C golang newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C rabbitmq newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C wordpress newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C jre-8 newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C elasticsearch newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C kibana newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C nginx-router newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C fake-sqs newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C wkhtmlpdf newtag=${newtag} registryUrl=$(registryUrl)
	$(MAKE) -C nginx-redirect newtag=${newtag} registryUrl=$(registryUrl)

push:
	docker push ${registryUrl}/opguk/base:${currenttag}
	docker push ${registryUrl}/opguk/base:latest
	docker push ${registryUrl}/opguk/nginx:${currenttag}
	docker push ${registryUrl}/opguk/nginx:latest
	docker push ${registryUrl}/opguk/php-fpm:${currenttag}
	docker push ${registryUrl}/opguk/php-fpm:latest
	docker push ${registryUrl}/opguk/golang:${currenttag}
	docker push ${registryUrl}/opguk/golang:latest
	docker push ${registryUrl}/opguk/rabbitmq:${currenttag}
	docker push ${registryUrl}/opguk/rabbitmq:latest
	docker push ${registryUrl}/opguk/wordpress:${currenttag}
	docker push ${registryUrl}/opguk/wordpress:latest
	docker push ${registryUrl}/opguk/jre-8:${currenttag}
	docker push ${registryUrl}/opguk/jre-8:latest
	docker push ${registryUrl}/opguk/elasticsearch:${currenttag}
	docker push ${registryUrl}/opguk/elasticsearch:latest
	docker push ${registryUrl}/opguk/kibana:${currenttag}
	docker push ${registryUrl}/opguk/kibana:latest
	docker push ${registryUrl}/opguk/nginx-router:${currenttag}
	docker push ${registryUrl}/opguk/nginx-router:latest
	docker push ${registryUrl}/opguk/fake-sqs:${currenttag}
	docker push ${registryUrl}/opguk/fake-sqs:latest
	docker push ${registryUrl}/opguk/wkhtmlpdf:${currenttag}
	docker push ${registryUrl}/opguk/wkhtmlpdf:latest
	docker push ${registryUrl}/opguk/nginx-redirect:${currenttag}
	docker push ${registryUrl}/opguk/nginx-redirect:latest

pull:
	docker pull ${registryUrl}/opguk/base
	docker pull ${registryUrl}/opguk/nginx
	docker pull ${registryUrl}/opguk/php-fpm
	docker pull ${registryUrl}/opguk/golang
	docker pull ${registryUrl}/opguk/rabbitmq
	docker pull ${registryUrl}/opguk/wordpress
	docker pull ${registryUrl}/opguk/jre-8
	docker pull ${registryUrl}/opguk/elasticsearch
	docker pull ${registryUrl}/opguk/kibana
	docker pull ${registryUrl}/opguk/nginx-router
	docker pull ${registryUrl}/opguk/fake-sqs
	docker pull ${registryUrl}/opguk/wkhtmlpdf
	docker pull ${registryUrl}/opguk/nginx-redirect

test:
	@echo Registry: ${registryUrl}
	@echo Newtag: ${newtag}
	@echo Current Tag: ${currenttag}
	@echo Container List: ${containers}