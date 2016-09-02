CORE_CONTAINERS := base nginx php-fpm jre-8
CHILD_CONTAINERS := golang rabbitmq wordpress elasticsearch elasticsearch-shared-data jenkins-slave jenkins kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect casperjs backupninja mongodb
CLEAN_CONTAINERS := $(CORE_CONTAINERS) $(CHILD_CONTAINERS)

.PHONY: build push pull showinfo test $(CORE_CONTAINERS) $(CHILD_CONTAINERS) clean

tagrepo = no
currenttag := $(shell semvertag latest)
#newtag := $(shell semvertag bump patch)
newtag = latest
registryUrl = registry.service.opg.digital
dockerVersion := $(shell docker --version | cut -f3 -d' '  | grep '^1\.[0-9]\.')

buildcore: $(CORE_CONTAINERS)
buildchild: $(CHILD_CONTAINERS)

build: buildcore buildchild
ifeq ($(tagrepo),yes)
	semvertag tag $(newtag)
else
	@echo -e Not tagging repo
endif

$(CORE_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl) dockerVersion=$(dockerVersion)

$(CHILD_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl) dockerVersion=$(dockerVersion)

push:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
       	    docker push $(registryUrl)/opguk/$$i:$(newtag) ; \
       	    docker push $(registryUrl)/opguk/$$i:latest ; \
   	done

pull:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
       	    docker pull $(registryUrl)/opguk/$$i ; \
   	done

showinfo:
	@echo Docker version: $(dockerVersion)
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

all: showinfo build push clean
