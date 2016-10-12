OPG Jenkins Slave docker image
==============================

Exposes port 22 for ssh, only allows key based authentication from jenkins

Dockerfile Environment Variables
--------------------------------

JENKINS_MASTER_AUTHKEYS - *Required* Public key for jenkins to ssh into the system
JENKINS_GITHUB_USERNAME - Github username for commits
JENKINS_GITHUB_EMAIL - Github email for commits
JENKINS_MASTER_URL - required for self registration
JENKINS_MASTER_PORT - the port we're connecting to, required
JENKINS_AUTH_TOKEN - required for authorisation for the build 
JENKINS_JOB_NAME - jenkins job name
SLAVE_HOST_IP - the ip of the slave

TODO
----

Add private key for github so that we can push from the slave

Example
-------

see [docker-compose.yml](docker-compose.yml)