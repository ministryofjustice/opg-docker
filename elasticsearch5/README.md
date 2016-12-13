OPG elasticsearch docker image
==============================

Dockerfile Environment Variables
--------------------------------

### Software versions (used during build only)

```
* ELASTICSEARCH_VERSION             (version of Elasticsearch to install)
* ELASTICSEARCH_CURATOR_VERSION     (version of Curator to install)
* ELASTICSEARCH_CLOUD_AWS           (version of AWS cloud plugin to install)
* LICENSE_VERSION                   (version of License plugin to install)
* WATCHER_VERSION                   (version of Watcher plugin to install)
```

### Elasticsearch Settings (used by confd during startup)

The following variables are used in the configuration of `elasticsearch.yml` during container startup and their
equivalent elasticsearch configuration variable is show alongside:

```
* ELASTICSEARCH_PATH_REPO                             (path.repo)
* ELASTICSEARCH_NUMBER_OF_REPLICAS                    (index.number_of_replicas)
* ELASTICSEARCH_NETWORK_BIND_HOST                     (network.bind_host)
* ELASTICSEARCH_NETWORK_PUBLISH_HOST                  (network.publish_host)
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

To allow AWS access/secret keys to be used (instead of IAM roles) for access to S3 storage for snapshots, the variables have been defined but left unset so that IAM is used in preference. Setting values for the key variables will override IAM and force the use of these keys when authenticating.

When using the `ELASTICSEARCH_CLUSTER_NODES_` variable(s) the suffix after this name is arbitrary. Each variable starting with this
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

### Elasticsearch Script Variables (used by scripts)

The following variables are used by scripts included in the container (stored in `/scripts/elasticsearch/`). See comments within the script for more details.

```
* ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE             (Snapshot repo type)
* ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME             (Snapshot repo name)
* ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET        (S3 bucket for repo)
* ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_PATH          (Used to build path to repo in S3)
* ELASTICSEARCH_SNAPSHOTS_REPOSITORY_FS_PATH          (Local directory for repo)
* ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS                 (How many days to keep snapshots)
```

Sample docker-compose entries
-----------------------------

### Elasticsearch (single node, no replicas)

```
elasticsearch:
  image: registry.service.opg.digital/opguk/elasticsearch:latest
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
  image: registry.service.opg.digital/opguk/elasticsearch:latest
  links:
    - elasticsearch02:elasticsearch-02
  ports:
    - 9201:9200
  env_file: ./env/es1.env

elasticsearch02:
  image: registry.service.opg.digital/opguk/elasticsearch:latest
  links:
    - elasticsearch03:elasticsearch-03
  ports:
    - 9202:9200
  env_file: ./env/es2.env

elasticsearch03:
  image: registry.service.opg.digital/opguk/elasticsearch:latest
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
  image: registry.service.opg.digital/opguk/elasticsearch:latest
  external_links:
    - opgcoredocker_elasticsearch_1:elasticsearch
```

Assuming a running elasticsearch container has been started as above, to run curator against it:

```
 # docker-compose -f <docker-compose-file> run elasticcurator curator --host elasticsearch.......
```

### Snapshots

```
elasticsnapshot:
  image: registry.service.opg.digital/opguk/elasticsearch:latest
  external_links:
    - opgcoredocker_elasticsearch_1:elasticsearch
```

Assuming a running elasticsearch container has been started as above, to define a repository for snapshots called `my_snaps`:

```
 # docker-compose -f <docker-compose-file> run elasticsnapshot \
 curl -XPUT "http://elasticsearch:9200/_snapshot/my_snaps" -d '{
    "type": "fs",
    "settings": {
       "location": "my_snaps"
    }
 }'
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

Snapshots
---------

#### Taking Snapshots

There is a script included within the container called `/scripts/elasticsearch/snapshot_elastic.sh`, which will use variables defined in the Dockerfile to create a snapshot repository, take a snapshot of all indices and remove previous snapshots older than a certain number of days. The script also uses sensible defaults if those variables are not set.

Using the sample compose entries above, to take a snapshot to a repository called `mysnapshots` on an S3 bucket called `s3_snapshots` and remove copies older than 3 days:

```
 # docker-compose -f <docker-compose-file> run \
 -e ELASTICSEARCH_SNAPSHOTS_REPOSITORY_TYPE=s3 \
 -e ELASTICSEARCH_SNAPSHOTS_REPOSITORY_S3_BUCKET=s3_snapshots \
 -e ELASTICSEARCH_SNAPSHOTS_REPOSITORY_NAME=mysnapshots \
 -e ELASTICSEARCH_SNAPSHOTS_RETAIN_DAYS=3 \
 elasticsnapshot /scripts/elasticsearch/snapshot_elastic.sh
```

### Restoring Snapshots

To restore from a snapshot, the process that works best is to close all indices, restore from the snapshot, close them all again and then open them all. Open indices cannot be restored (hence closing all before restoring).

Assuming the use of the `elasticsnapshot` service used above to demonstrate snapshots, to restore from a snapshot called `snaptest` from a repository called `testrepo`:

```
 # docker-compose -f <docker-compose-file> run elasticsnapshot \
 curl -XPOST http://elasticsearch:9200/_all/_close?wait_for_completion=true?ignore_unavailable=true
 #
 # docker-compose -f <docker-compose-file> run elasticsnapshot \
 curl -XPOST curl -XPOST http://elasticsearch:9200/_snapshot/testrepo/snaptest/_restore?wait_for_completion=true?ignore_unavailable=true
 #
 # docker-compose -f <docker-compose-file> run elasticsnapshot \
 curl -XPOST http://elasticsearch:9200/_all/_close?wait_for_completion=true?ignore_unavailable=true
 ```

### Sample Restore

The following is a console log session from an actual restore of the monitoring stack Elasticsearch `logstash` indices from production snapshots using the latest snapshot name at the time of restore (`curator-20151211010005`). The example shows selected indices being restored (default is `all` so this example shows how to restore a subset, which is a more likely scenario). The indices restored in this example are `logstash-2015.06.14,logstash-2015.10.14,logstash-2015.12.11`.

The example uses a fresh docker container started in order to define a snapshot repo that points to the actual (live) repository in the S3 bucket, which can then be used to restore from. In this example the restore repository is called `testing`. It also uses a fresh container on the `monitoring-01` host as it has IAM rights to be able to read from the snapshot (S3) bucket so any alternative host would need similar access.  

To avoid TCP port clash with the monitoring stack, port 9200 is mapped to host port 19200 to allow SSH port forwarding to allow access to the Marvel dashboard to prove document counts, dates, etc once restored. Spinning up a fresh container also proves that in the event the live instance is hosed completely that data can be pulled from snapshots to a brand new one.

Note: a full list of indices within the snapshot has been shortened for the sake of brevity.

```
(production01)root@monitoring-01:~# docker run -itd -p 19200:9200 registry.service.opg.digital/opguk/elasticsearch:0.1.97
ce04387a7992ddc6809d5b180ea3f0c56633537959d513874dc21dfb42f7f2a7
(production01)root@monitoring-01:~#
(production01)root@monitoring-01:~# docker exec -it ce04387a7992 bash -o vi
root@ce04387a7992:/# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  1 12:09 ?        00:00:00 /usr/bin/python3 -u /sbin/my_init
root        18     1  0 12:09 ?        00:00:00 /usr/bin/runsvdir -P /etc/service
root        19    18  0 12:09 ?        00:00:00 runsv cron
root        20    18  0 12:09 ?        00:00:00 runsv syslog-forwarder
root        21    18  0 12:09 ?        00:00:00 runsv syslog-ng
root        22    18  0 12:09 ?        00:00:00 runsv beaver
root        23    18  0 12:09 ?        00:00:00 runsv dnsmasq
root        24    18  0 12:09 ?        00:00:00 runsv elasticsearch
root        25    20  0 12:09 ?        00:00:00 tail -f -n 0 /var/log/syslog
root        26    19  0 12:09 ?        00:00:00 /usr/sbin/cron -f
root        27    21  0 12:09 ?        00:00:00 syslog-ng -F -p /var/run/syslog-ng.pid --no-caps
elastic+    28    24 89 12:09 ?        00:00:09 /usr/bin/java -Xms256m -Xmx1g -Djava.awt.headless=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDum
root        31    23  0 12:09 ?        00:00:00 /usr/sbin/dnsmasq -u root -k
root       138     0  1 12:09 ?        00:00:00 bash -o vi
root       144   138  0 12:09 ?        00:00:00 ps -ef
root@ce04387a7992:/# curator show indices --all-indices
2015-12-11 12:09:44,897 INFO      Job starting: show indices
2015-12-11 12:09:44,911 INFO      Matching all indices. Ignoring flags other than --exclude.
2015-12-11 12:09:44,911 INFO      Matching indices:
.marvel-2015.12.11
root@ce04387a7992:/# curl -XPUT http://localhost:9200/_snapshot/testing?verify=false -d '{
> "type": "s3",
> "settings": {
>   "bucket": "opg-backoffice-dbsnapshot-production01",
>   "base_path": "monitoring-01.production01.sirius-opg.uk/es-snapshots"
>   }
> }'

{"acknowledged":true}
root@ce04387a7992:/# curl -XGET http://localhost:9200/_snapshot/testing/_all?pretty
{
  "snapshots" : [ {
    "snapshot" : "curator-20151210103317",
    "indices" : [ ".kibana", ".marvel-2015.07.31", ".marvel-2015.08.01", ".marvel-2015.08.02"..............
    "state" : "SUCCESS",
    "start_time" : "2015-12-10T10:33:17.133Z",
    "start_time_in_millis" : 1449743597133,
    "end_time" : "2015-12-10T17:58:13.906Z",
    "end_time_in_millis" : 1449770293906,
    "duration_in_millis" : 26696773,
    "failures" : [ ],
    "shards" : {
      "total" : 1089,
      "failed" : 0,
      "successful" : 1089
    }
  }, {
    "snapshot" : "curator-20151211010005",
    "indices" : [ ".kibana", ".marvel-2015.07.31", ".marvel-2015.08.01", ".marvel-2015.08.02"............
    "state" : "SUCCESS",
    "start_time" : "2015-12-11T01:00:06.033Z",
    "start_time_in_millis" : 1449795606033,
    "end_time" : "2015-12-11T01:03:22.879Z",
    "end_time_in_millis" : 1449795802879,
    "duration_in_millis" : 196846,
    "failures" : [ ],
    "shards" : {
      "total" : 1095,
      "failed" : 0,
      "successful" : 1095
    }
  } ]
}
root@ce04387a7992:/# curl -XPOST "http://localhost:9200/_all/_close?wait_for_completion=true?ignore_unavailable=true"

{"acknowledged":true}
root@ce04387a7992:/# curl -XPOST "http://localhost:9200/_snapshot/testing/curator-20151211010005/_restore?wait_for_completion=true?ignore_unavailable=true" -d '{
> "indices": "logstash-2015.06.14,logstash-2015.10.14,logstash-2015.12.11"
> }'

{"snapshot":{"snapshot":"curator-20151211010005","indices":["logstash-2015.06.14","logstash-2015.12.11","logstash-2015.10.14"],"shards":{"total":15,"failed":0,"successful":15}}}
root@ce04387a7992:/#
root@ce04387a7992:/# curl -XPOST "http://localhost:9200/_all/_close?wait_for_completion=true?ignore_unavailable=true"

{"acknowledged":true}
root@ce04387a7992:/# curl -XPOST "http://localhost:9200/_all/_open?wait_for_completion=true?ignore_unavailable=true"

{"acknowledged":true}
root@ce04387a7992:/#
root@ce04387a7992:/# curator show indices --all-indices
2015-12-11 12:18:29,617 INFO      Job starting: show indices
2015-12-11 12:18:29,628 INFO      Matching all indices. Ignoring flags other than --exclude.
2015-12-11 12:18:29,628 INFO      Matching indices:
.marvel-2015.12.11
logstash-2015.06.14
logstash-2015.10.14
logstash-2015.12.11
root@ce04387a7992:/#
root@ce04387a7992:~# exit
```

### More Information

For more information on configuring, taking, restoring from and deleting snapshots:

https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html

To snapshot to AWS (S3) using the AWS Cloud Plugin:

https://github.com/elastic/elasticsearch-cloud-aws

