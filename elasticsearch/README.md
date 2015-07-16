OPG elasticsearch docker image
==============================

Dockerfile Environment Variables
--------------------------------

### Software versions (used during build only)

* ELASTICSEARCH_VERSION             (version of Elasticsearch to install)
* ELASTICSEARCH_CURATOR_VERSION     (version of Curator to install)
* MARVEL_VERSION                    (version of Marvel plugin to install)
* LICENSE_VERSION                   (version of License plugin to install)
* WATCHER_VERSION                   (version of Watcher plugin to install)

### Elasticsearch Settings (used by confd during startup)

* ELASTICSEARCH_NUMBER_OF_REPLICAS  (number of replicas to use on indices)

Sample docker-compose entries
-----------------------------

### Elasticsearch

```
elasticsearch:
  image: registry.service.dsd.io/opguk/elasticsearch:latest
  ports:
    - 9200:9200
```

Start container with:

```
 # docker-compose -p opgcore -f <docker-compose-file> up -d elasticsearch
```

### Curator

```
elasticcurator:
  image: registry.service.dsd.io/opguk/elasticsearch:latest
  external_links:
    - opgcoredocker_elasticsearch_1:elasticsearch
```

Assuming a running elasticsearch container has been started as above, to run curator against it:

```
 # docker-compose -f <docker-compose-file> run elasticcurator curator --host elasticsearch.......
```

Curator
-------
Using the sample compose entries above and the example to run curator above -

To get help on the curator command:

` curator --help`

To list all current indices:

` curator --host elasticsearch show indices --all-indices`

To do a dry run housekeep of marvel indices older than 30 days:

` curator --dry-run --host elasticsearch delete indices --time-unit days --older-than 30 --timestring '%Y.%m.%d' --prefix '.marvel'`

To delete all indices on the master node only:

` curator --master-only --host elasticsearch delete indices --all-indices`

Marvel
------

The URL for Marvel is `http://<elasticsearchhost>:9200/_plugins/marvel`
