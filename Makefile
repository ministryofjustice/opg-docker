CORE_CONTAINERS := base nginx php-fpm jre-8
CHILD_CONTAINERS := golang rabbitmq wordpress elasticsearch kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect
CLEAN_CONTAINERS := $(CORE_CONTAINERS) $(CHILD_CONTAINERS)

.PHONY: build push pull showinfo test $(CORE_CONTAINERS) $(CHILD_CONTAINERS) clean

tagrepo = yes
currenttag := $(shell semvertag latest)
newtag := $(shell semvertag bump patch)
registryUrl = registry.service.opg.digital

buildcore: $(CORE_CONTAINERS)
buildchild: $(CHILD_CONTAINERS)

build: buildcore buildchild
ifeq ($(tagrepo),yes)
	semvertag tag $(newtag)
else
	@echo -e Not tagging repo
endif

$(CORE_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl)

$(CHILD_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl)

push:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
       	    docker push $(registryUrl)/opguk/$$i:$(currenttag) ; \
       	    docker push $(registryUrl)/opguk/$$i:latest ; \
   	done

pull:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
       	    docker pull $(registryUrl)/opguk/$$i ; \
   	done

showinfo:
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
       	    docker rmi $(registryUrl)/opguk/$$i:$(newtag) || true ; \
       	    docker rmi $(registryUrl)/opguk/$$i:latest || true ; \
   	done
