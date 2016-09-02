OPG kibana docker image
==============================

Dockerfile Environment Variables
--------------------------------

### Software versions (used during build only)

* ELASTICSEARCH (Elasticsearch endpoint)
* KIBANA_INDEX (kibana index)
* DEFAULT_APP_ID (default app id)
* REQUEST_TIMEOUT (request timeout)
* SHARD_TIMEOUT (shard timeout)
* VERIFY_SSL (verify ssl)

Sample docker-compose entries
-----------------------------

### Kibana

```
kibana:
  image: registry.service.opg.digital/opguk/kibana:latest
  elasticsearch: http://localhost:9200
  kibana_index: .kibana
  default_app_id: discover
  request_timeout: 300000
  share_timeout: 0
  verify_ssl: true
```

Start container with:

```
 # docker-compose -p opgcore -f <docker-compose-file> up -d kibana
```
