opguk/mongodb
=================

MongoDB container including supporting scripts for initial setup to DB, creation of users & indexes and restoring the database from backup files.

Supported variables
-------------------

* MONGO_SECURITY_AUTH - Require admin login? (Recommended: `True`)
* MONGO_REPLICASET_NAME - The name of the default replica set (e.g.: `rs0`)
* MONGO_ADMIN_PASSWORD - The password of the admin user
* MONGO_RS_HOSTS - A comma seperated list of hosts in the replica set (e.g.: `mongodb-01,mongodb-02,mongodb-03`)
* MY_HOSTNAME - The name of the server the container is running on - ideally set with salt grain (e.g.: `mongodb-01`)
* MONGO_SSL_PEM - Contents of Mongo PEM file to use
* MONGO_SSL_CACERT - Contents of Cert CA file to use
* MONGO_SECURITY_KEY - Contents of security key to use
* SKIP_SETUP - If set to `True`, then the automatic configuration of replica sets, users and indexs will be skipped

* MONGO_USER_1,MONGO_USER_2,MONGO_USER_3,... - Set as many of these as you need to create users on startup (see below)
* MONGO_INDEX_1,MONGO_INDEX_2,MONGO_INDEX_3,... - Set as many of these as you need to create indexes on startup (see below)

This container inherits from the [opg/backupninja container](https://github.com/ministryofjustice/opg-docker/tree/master/backupninja) and as such also inherits its environment variables. Please see the relevant [READMD.md](https://github.com/ministryofjustice/opg-docker/blob/master/backupninja/README.md) to understand these additional environment variables.

Automated configuration
-----------------------

By default, the container will wait 60 seconds upon startup, then check if it's the first host in the host list and, if it is, start configuring the database. It will:

* Set up the replica setup
* Create an admin user
* Create any additional users specified in the `MONGO_USER_*` environment variables
* Create any indexes specified in the `MONGO_INDEX_*` environment variables

The format for the `MONGO_USER_*` environment variables is:

```
'database_name|username|password|role'
```

e.g.

```
MONGO_USER_1='opg-shared-test|user123|p4ssword|readWrite'
```

The format for the `MONGO_INDEX_*` environment variables is:

```
'database_name|collection_name|index_definition'
```

e.g.

```
MONGO_INDEX_1='opg-shared-test|collection99|{ identity: 1 }, { unique: true, sparse: true }'
```

Note: all this configuration will be skipped in `SKIP_SETUP` is set to `True`.
