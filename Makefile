CORE_CONTAINERS := base nginx php-fpm jre-8
CHILD_CONTAINERS := golang rabbitmq wordpress elasticsearch kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect
CLEAN_CONTAINERS := $(CORE_CONTAINERS) $(CHILD_CONTAINERS)

.PHONY: build push pull test $(CORE_CONTAINERS) $(CHILD_CONTAINERS) clean
tagrepo = yes
currenttag := $(shell semvertag latest)
newtag := $(shell semvertag bump patch)
registryUrl = registry.service.opg.digital

buildcore: $(CORE_CONTAINERS)
buildchild: $(CHILD_CONTAINERS)

build: buildcore buildchild
ifeq ($tagrepo,yes)
	semvertag tag $(newtag)
else
	@echo -e Not tagging repo
endif

$(CORE_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl)

$(CHILD_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl)

push:
	docker push $(registryUrl)/opguk/base:$(currenttag)
	docker push $(registryUrl)/opguk/base:latest
	docker push $(registryUrl)/opguk/nginx:$(currenttag)
	docker push $(registryUrl)/opguk/nginx:latest
	docker push $(registryUrl)/opguk/php-fpm:$(currenttag)
	docker push $(registryUrl)/opguk/php-fpm:latest
	docker push $(registryUrl)/opguk/golang:$(currenttag)
	docker push $(registryUrl)/opguk/golang:latest
	docker push $(registryUrl)/opguk/rabbitmq:$(currenttag)
	docker push $(registryUrl)/opguk/rabbitmq:latest
	docker push $(registryUrl)/opguk/wordpress:$(currenttag)
	docker push $(registryUrl)/opguk/wordpress:latest
	docker push $(registryUrl)/opguk/jre-8:$(currenttag)
	docker push $(registryUrl)/opguk/jre-8:latest
	docker push $(registryUrl)/opguk/elasticsearch:$(currenttag)
	docker push $(registryUrl)/opguk/elasticsearch:latest
	docker push $(registryUrl)/opguk/kibana:$(currenttag)
	docker push $(registryUrl)/opguk/kibana:latest
	docker push $(registryUrl)/opguk/jenkins:$(currenttag)
	docker push $(registryUrl)/opguk/jenkins:latest
	docker push $(registryUrl)/opguk/nginx-router:$(currenttag)
	docker push $(registryUrl)/opguk/nginx-router:latest
	docker push $(registryUrl)/opguk/fake-sqs:$(currenttag)
	docker push $(registryUrl)/opguk/fake-sqs:latest
	docker push $(registryUrl)/opguk/wkhtmlpdf:$(currenttag)
	docker push $(registryUrl)/opguk/wkhtmlpdf:latest
	docker push $(registryUrl)/opguk/nginx-redirect:$(currenttag)
	docker push $(registryUrl)/opguk/nginx-redirect:latest

pull:
	docker pull $(registryUrl)/opguk/base
	docker pull $(registryUrl)/opguk/nginx
	docker pull $(registryUrl)/opguk/php-fpm
	docker pull $(registryUrl)/opguk/golang
	docker pull $(registryUrl)/opguk/rabbitmq
	docker pull $(registryUrl)/opguk/wordpress
	docker pull $(registryUrl)/opguk/jre-8
	docker pull $(registryUrl)/opguk/elasticsearch
	docker pull $(registryUrl)/opguk/kibana
	docker pull $(registryUrl)/opguk/jenkins
	docker pull $(registryUrl)/opguk/nginx-router
	docker pull $(registryUrl)/opguk/fake-sqs
	docker pull $(registryUrl)/opguk/wkhtmlpdf
	docker pull $(registryUrl)/opguk/nginx-redirect

test:
	@echo Registry: $(registryUrl)
	@echo Newtag: $(newtag)
	@echo Current Tag: $(currenttag)
	@echo Core Container List: $(CORE_CONTAINERS)
	@echo Container List: $(CHILD_CONTAINERS)
	@echo Clean Container List: $(CLEAN_CONTAINERS)
ifeq ($(tagrepo),yes)
	@echo Tagging repo: $(tagrepo)
endif

clean:
	for i in $(CLEAN_CONTAINERS); do \
       	    docker rmi $(registryUrl)/opguk/$$i:$(newtag) ; \
       	    docker rmi $(registryUrl)/opguk/$$i:latest ; \
   	done
