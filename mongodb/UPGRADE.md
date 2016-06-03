# Upgrading running MongoDB containers

Due to the fact that all running MongoDB containers should belong to a live replica set, the upgrade process is slightly complicated. This is a step-by-step guide to upgrading all the containers in a three hosts replica set. If should be fairly obvious how to adapt the instructions if you have more that three hosts.

For the purposes of these instructions, we will assume that the first host (mongodb-01) is the primary. We will upgrade the primary host last so that only one failover is required, thereby minimising downtime.

For each of the interactions with mongo itself, if the salt master has the `mongo` client installed, then you are best connecting from there. If not, then you will need to connect from one of the hosts that you are not upgrading at that point in time.


### Upgrade mongodb-02

Connect to the replica set primary node, check the health of the replica set and replication status and then remove the host to be upgraded if all looks ok:

```
salt# mongo --host mongodb-01 admin -u <admin_user> -p <admin_password>
PRIMARY> rs.status();
PRIMARY> rs.printSlaveReplicationInfo();
PRIMARY> rs.remove("mongodb-02:27017");
```

As Mongo uses the "latest" tag rather than a pinned build, you'll need to delete the docker image from the host so it has to download it again. Run the following on the host running the MongoDB container:

```
ip-10-0-2-yy# docker ps # find the name of your MongoDB container
ip-10-0-2-yy# docker stop <container_name>
ip-10-0-2-yy# docker rm <container_name>
ip-10-0-2-yy# docker images # find the name of your MongoDB images
ip-10-0-2-yy# docker rmi <container_image_name>
```

Now on the salt master we can run a highstate to bring the container back up:

```
salt# salt 'ip-10-0-2-yy' state.highstate
```

Once the command has returned successfully, you can add the host back into the replica set:

```
salt# mongo --host mongodb-01 admin -u <admin_user> -p <admin_password>
PRIMARY> rs.add({_id: 1, host: "mongodb-02:27017"});
PRIMARY> rs.status();
PRIMARY> rs.printSlaveReplicationInfo();
```

Ensure it is correctly added and syncing.


### Upgrade mongodb-03

The exact same process can be used on mongodb-03 (and any additional non-primary nodes) as for mongodb-02. Ensure though that the commands above show that the replica set is fully healthy and in sync before commencing.

Also remember to change the `_id` field in the `rs.add()` command as it's easily forgotten (first host has id of 0)


### Upgrade mongodb-01 (the primary)

This host is slightly more complicated due to some issues with getting it running in a container and setting up the replica set when it starts up. As the replica set is already created, we need to skip that part. Let's go...

First we need to remove the host from the replica set. As the mongo process is running in a container it's not able to verify its own name is mongodb-01, so we need to remove it in a different way:

```
salt# mongo --host mongodb-01 admin -u <admin_user> -p <admin_password>
PRIMARY> db.shutdownServer();
```

Note that this is the point as which you might have some intermittent connectivity issues for a couple of minutes.

Determine which the is the new primary by connecting to one of the remain hosts and running `rs.status();`. Let's assume for this example that it's mongodb-03.

Connect to the primary and remove mongodb-01 from the replica set config:

```
salt# mongo --host mongodb-03 admin -u <admin_user> -p <admin_password>
PRIMARY> rs.conf();
PRIMARY> cfg = rs.conf();
PRIMARY> cfg.members.splice(0,1);
PRIMARY> rs.reconfig(cfg);
PRIMARY> rs.conf();
```

The last command should now show that mongodb-01 is no longer in the configuration. Now we can upgrade the container - run the following on the host running the MongoDB container:

```
ip-10-0-2-yy# docker ps # find the name of your MongoDB container
ip-10-0-2-yy# docker stop <container_name>
ip-10-0-2-yy# docker rm <container_name>
ip-10-0-2-yy# docker images # find the name of your MongoDB images
ip-10-0-2-yy# docker rmi <container_image_name>
```

We need to prevent the container self-configuring when it comes up, so edit `/srv/pillar/roles/mongodb.sls` and add `MONGO_SKIP_SETUP: True` into the mongodb environment section.

Now on the salt master we can run a highstate to bring the container back up:

```
salt# salt 'ip-10-0-1-xx' state.highstate
```

Once the command has returned successfully, you can add the host back into the replica set:

```
salt# mongo --host mongodb-03 admin -u <admin_user> -p <admin_password>
PRIMARY> rs.add({_id: 0, host: "mongodb-01:27017"});
PRIMARY> rs.status();
PRIMARY> rs.printSlaveReplicationInfo();
```

Ensure it is correctly added and syncing.

Wait for the health and sync status to be good and then we need to change the `MONGO_SKIP_SETUP` environment variable back as it's currently out of sync with our source pillars. Edit `/srv/pillar/roles/mongodb.sls` and remove the `MONGO_SKIP_SETUP: True` line.

Now on the salt master we can run a highstate again to bring the container back up correctly (as the replica set is now configured for the host, the auto-configuration won't change anything):

```
salt# salt 'ip-10-0-1-xx' state.highstate
```

Finally check the health of the replica set:

```
salt# mongo --host mongodb-03 admin -u <admin_user> -p <admin_password>
PRIMARY> rs.status();
PRIMARY> rs.printSlaveReplicationInfo();
```


That's it!!!!
