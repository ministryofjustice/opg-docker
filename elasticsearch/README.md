OPG elasticsearch docker image
==============================

Dockerfile Environment Variables
--------------------------------

### Software versions (used during build only)

```
* ELASTICSEARCH_VERSION             (version of Elasticsearch to install)
* ELASTICSEARCH_CURATOR_VERSION     (version of Curator to install)
* ELASTICSEARCH_CLOUD_AWS           (version of AWS cloud plugin to install)
* MARVEL_VERSION                    (version of Marvel plugin to install)
* LICENSE_VERSION                   (version of License plugin to install)
* WATCHER_VERSION                   (version of Watcher plugin to install)
```

### Elasticsearch Settings (used by confd during startup)

The following variables are used in the configuration of elasticsearch.yml during container startup and their
equivalent elasticsearch configuration variable is show alongside:

```
* ELASTICSEARCH_PATH_REPO                             (path.repo)
* ELASTICSEARCH_NUMBER_OF_REPLICAS                    (index.number_of_replicas)
* ELASTICSEARCH_NETWORK_BIND_HOST                     (network.bind_host)
* ELASTICSEARCH_SCRIPT_DISABLE_DYNAMIC                (script.disable_dynamic)
* ELASTICSEARCH_PATH_DATA                             (path.data)
* ELASTICSEARCH_DISCOVERY_ZEN_PING_MULTICASE_ENABLED  (discovery.zen.ping.multicast.enabled)
* ELASTICSEARCH_DISCOVERY_ZEN_MINIMUM_MASTER_NODES    (discovery.zen.minimum_master_nodes)
* ELASTICSEARCH_CLUSTER_NAME                          (cluster.name)
* ELASTICSEARCH_CLUSTER_NODES_ONE                     (discovery.zen.ping.unicast.hosts)
* ELASTICSEARCH_NODE_NAME                             (node.name)
* ELASTICSEARCH_INDICES_FIELDDATA_CACHE_SIZE          (indices.fielddata.cache.size)
* ELASTICSEARCH_GATEWAY_EXPECTED_NODES                (gateway.expected_nodes)
* ELASTICSEARCH_GATEWAY_RECOVER_AFTER_TIME            (gateway.recover_after_time)
* ELASTICSEARCH_GATEWAY_RECOVER_AFTER_NODES           (gateway.recover_after_nodes)
* ELASTICSEARCH_CLOUD_AWS_REGION                      (cloud.aws.region)
* ELASTICSEARCH_CLOUD_AWS_S3_PROTOCOL                 (cloud.aws.s3.protocol)
* ELASTICSEARCH_CLOUD_AWS_ACCESS_KEY                  (cloud.aws.access_key)
* ELASTICSEARCH_CLOUD_AWS_SECRET_KEY                  (cloud.aws.secret_key)
```

When using the ELASTICSEARCH_CLUSTER_NODES_ variable(s) the suffix after this name is arbitrary. Each variable starting with this
name will be used as a key in the template used to create the elasticsearch.yml configuration file to populate the list of nodes
in the cluster. For example:

```
ELASTICSEARCH_CLUSTER_NODES_ONE elastic-01
ELASTICSEARCH_CLUSTER_NODES_TWO elastic-02
ELASTICSEARCH_CLUSTER_NODES_THREE elastic-03
```

will result in the elasticsearch.yml file containing:

```
discovery.zen.ping.unicast.hosts:
- elastic-01
- elastic-02
- elastic-03
````

If this is a single node cluster comment out the `ELASTICSEARCH_CLUSTER_NODES_` variables as they are not required and will
automatically be left out of the configuration file (otherwise during startup it will generate transport.netty transport
layer exception messages from java).

Sample docker-compose entries
-----------------------------

### Elasticsearch (single node, no replicas)

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

### Elasticsearch (three nodes, two replicas)

```
elasticsearch01:
  image: registry.service.dsd.io/opguk/elasticsearch:latest
  links:
    - elasticsearch02:elasticsearch-02
  ports:
    - 9201:9200
  env_file: ./env/es1.env

elasticsearch02:
  image: registry.service.dsd.io/opguk/elasticsearch:latest
  links:
    - elasticsearch03:elasticsearch-03
  ports:
    - 9202:9200
  env_file: ./env/es2.env

elasticsearch03:
  image: registry.service.dsd.io/opguk/elasticsearch:latest
  ports:
    - 9203:9200
  env_file: ./env/es3.env
```

Environment files

```
$ cat ./env/es1.env
ELASTICSEARCH_NUMBER_OF_REPLICAS=2
ELASTICSEARCH_NODE_NAME=elasticsearch-01
ELASTICSEARCH_CLUSTER_NODES_ONE=elasticsearch-01
ELASTICSEARCH_CLUSTER_NODES_TWO=elasticsearch-02
ELASTICSEARCH_CLUSTER_NODES_THREE=elasticsearch-03

$ cat ./env/es2.env
ELASTICSEARCH_NUMBER_OF_REPLICAS=2
ELASTICSEARCH_NODE_NAME=elasticsearch-02
ELASTICSEARCH_CLUSTER_NODES_ONE=elasticsearch-01
ELASTICSEARCH_CLUSTER_NODES_TWO=elasticsearch-02
ELASTICSEARCH_CLUSTER_NODES_THREE=elasticsearch-03

$ cat ./env/es3.env
ELASTICSEARCH_NUMBER_OF_REPLICAS=2
ELASTICSEARCH_NODE_NAME=elasticsearch-03
ELASTICSEARCH_CLUSTER_NODES_ONE=elasticsearch-01
ELASTICSEARCH_CLUSTER_NODES_TWO=elasticsearch-02
ELASTICSEARCH_CLUSTER_NODES_THREE=elasticsearch-03
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

The URL for Marvel is `http://<elasticsearchhost>:9200/_plugin/marvel`
