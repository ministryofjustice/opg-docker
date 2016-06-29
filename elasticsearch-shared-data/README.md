OPG elasticsearch-shared-data docker image
==========================================

A simple way to get various dashboards/templates and indexes into elasticsearch

All output is logged to `/var/log/elastic-scripts.log` in the elasticsearch container

Dockerfile Environment Variables
--------------------------------

### Software versions (used during build only)

```
None
```

### Elasticsearch Settings (used by confd during startup)

The following variables are used in the configuration of `elasticsearch.yml` during container startup and their
equivalent elasticsearch configuration variable is show alongside:

```
none
```

Sample docker-compose entry
---------------------------

New variables for elasticsearch
```
  environment:
    SHARED_DATA_BASE: # Base path to where our files are being installed from
    SHARED_DATA_PATHS: # A pythonic list of paths relative to `SHARED_BASE_PATH` in which to recursivley find and install elasticsearch scripts
    DASHBOARD_SLEEP_TIMEOUT: # A timeout to ensure that the elastic dashboard indices are up and ready so we can install our scripts
  volumes:
    - #Our elastic search script path default /tmp/elasticsearchshareddata
  volumes_from:
    - #Our elasticsearch-shared-data dockerfile image name
```

Note the special formatting of `SHARED_DATA_PATHS`, this is parsed to a 
python list so the formatting needs to match one that python will understand

ie:
```
['path', 'path', 'path']
```

[Example docker-compose](docker-compose.yml)


Index-patterns
--------------

Due to the generic nature of the import script any index-patterns need to have their title field named to reflect the index name,
this is due to the way we need to import the patterns from the json files

