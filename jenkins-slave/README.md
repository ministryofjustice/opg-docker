OPG Jenkins Slave docker image
==============================

Exposes port 2222 for ssh, only allows key based authentication from jenkins

Dockerfile Environment Variables
--------------------------------

JENKINS_MASTER_AUTHKEYS - *Required* Public key for jenkins to ssh into the system
JENKINS_GITHUB_USERNAME - Github username for commits
JENKINS_GITHUB_EMAIL - Github email for commits

TODO
----

Add private key for github so that we can push from the slave

Example
-------

see [docker-compose.yml](docker-compose.yml)