CORE_CONTAINERS := base nginx php-fpm jre-8 backupninja
CHILD_CONTAINERS := golang rabbitmq wordpress elasticsearch elasticsearch-shared-data jenkins-slave jenkins kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect casperjs  mongodb
CLEAN_CONTAINERS := $(CORE_CONTAINERS) $(CHILD_CONTAINERS)

.PHONY: build push pull showinfo test $(CORE_CONTAINERS) $(CHILD_CONTAINERS) clean

tagrepo = no
ifdef stage
	stagearg := --stage $(stage)
endif

currenttag := $(shell semvertag latest $(stagearg))
newtag := $(shell semvertag bump patch $(stagearg))

registryUrl = registry.service.opg.digital
oldRegistryUrl = registry.service.dsd.io

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
			[ "$(tagrepo)" = "yes" ] && docker push $(registryUrl)/opguk/$$i ; \
			docker push $(registryUrl)/opguk/$$i:$(newtag) ; \
	done
	#push to old registry
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
			[ "$(tagrepo)" = "yes" ] && docker push $(oldRegistryUrl)/opguk/$$i ; \
			docker push $(oldRegistryUrl)/opguk/$$i:$(newtag) ; \
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
		docker rmi $(oldRegistryUrl)/opguk/$$i || true ; \
		docker rmi $(registryUrl)/opguk/$$i:$(newtag) || true ; \
		docker rmi $(oldRegistryUrl)/opguk/$$i:$(newtag) || true ; \
		docker rmi $(registryUrl)/opguk/$$i || true ; \
	done

all: showinfo build push clean
