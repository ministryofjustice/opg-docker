CORE_CONTAINERS := base nginx nginx2 php-fpm jre-8 backupninja
CHILD_CONTAINERS := golang rabbitmq wordpress elasticsearch elasticsearch-shared-data jenkins-slave jenkins kibana nginx-router fake-sqs wkhtmlpdf nginx-redirect casperjs  mongodb elasticsearch5
CLEAN_CONTAINERS := $(CORE_CONTAINERS) $(CHILD_CONTAINERS)

.PHONY: build push pull showinfo test $(CORE_CONTAINERS) $(CHILD_CONTAINERS) clean

tagrepo = no
ifneq ($(stage),)
	stagearg = --stage $(stage)
endif

ifdef buildArgs
	no-cache := --no-cache
endif

currenttag = $(shell semvertag latest $(stagearg))
ifneq ($(findstring ERROR, $(currenttag)),)
    currenttag = 0.0.0
    ifneq ($(stage),)
        currenttag = 0.0.0-$(stage)
    endif        
endif        

newtag = $(shell semvertag bump patch $(stagearg))
ifneq ($(findstring ERROR, $(newtag)),)
    newtag = 0.0.1
    ifneq ($(stage),)
        newtag = 0.0.1-$(stage)
    endif        
endif        

registryUrl = registry.service.opg.digital
oldRegistryUrl = registry.service.dsd.io

buildcore: $(CORE_CONTAINERS)
buildchild: $(CHILD_CONTAINERS)

build: buildcore buildchild


$(CORE_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl) no-cache=$(no-cache)

$(CHILD_CONTAINERS):
	$(MAKE) -C $@ newtag=$(newtag) registryUrl=$(registryUrl) no-cache=$(no-cache)

push:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
			[ "$(stagearg)x" = "x" ] && docker push $(registryUrl)/opguk/$$i ; \
			docker push $(registryUrl)/opguk/$$i:$(newtag) ; \
	done
ifeq ($(tagrepo),yes)
	@echo -e Tagging repo
	semvertag tag $(newtag)
else
	@echo -e Not tagging repo
endif
	#push to old registry
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
			[ "$(stagearg)x" = "x" ] && docker push $(oldRegistryUrl)/opguk/$$i ; \
			docker push $(oldRegistryUrl)/opguk/$$i:$(newtag) ; \
	done

pull:
	for i in $(CORE_CONTAINERS) $(CHILD_CONTAINERS); do \
			docker pull $(registryUrl)/opguk/$$i ; \
	done

showinfo:
	@echo Registry: $(registryUrl)
	@echo Newtag: $(newtag)
	@echo Stage: $(stagearg)
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
		docker rmi $(registryUrl)/opguk/$$i:$(currenttag) || true ; \
		docker rmi $(oldRegistryUrl)/opguk/$$i:$(currenttag) || true ; \
		docker rmi $(registryUrl)/opguk/$$i || true ; \
	done

all: showinfo build push clean
