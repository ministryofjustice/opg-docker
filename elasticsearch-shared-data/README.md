OPG elasticsearch-shared-data docker image
==========================================

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