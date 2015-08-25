# OPG Jenkins Docker Image

The Jenkins Continuous Integration and Delivery server.

![jenkins_moj_logo](https://cloud.githubusercontent.com/assets/13198078/9408279/47665d26-4809-11e5-9c3f-4113dd3aa07e.png)

# To Make And Build
This [docker](https://www.docker.com/) build environment contains two possible containers.

1. [MOJ](https://www.youtube.com/watch?v=nr90nbqxuZk) docker container
2. [Amazon](http://www.sheppardsoftware.com/images/South%20America/factfile/Amazon_Rainforest.jpg) ECS docker container

The reason being two, is that Amazon ECS runs it's own service [(like my_init and runit)](https://github.com/phusion/baseimage-docker) which cleans up [zombie](http://3.bp.blogspot.com/-LE9q0n6-hKg/TqQI-NneSzI/AAAAAAAAAYs/a0GpdT5aBHE/s1600/npc_44_fat_zombie.png) processes and respawns the entrypoint. Hence if the entrypoint is ```/sbin/my_init```, (as in the MOJ containers) it will run this and kill the runit process stopping the container. At which point it will start ```/sbin/my_init``` again, and so on...

To make the MOJ container image run
```
  make
```
and push when complete:
```
  docker push registry.service.dsd.io/opguk/jenkins
```
etc.
## Plugins
Jenkins plugins are installed via a script, you can configure the plugins that you want to be installed by editing the 
```
  usr/share/jenkins/ref/plugins.txt
```
file, so install the *greenballs* plugin you would simply add edit the file like so,
```
  ...
  xunit
  plain-credentials
  workflow-step-api
  greenballs
```
and then run your make command.
## Clean Up You Slob!
If you want to nuke your docker builds and cleanup your computer of all docker containers and images, run the ```./docker-clean``` script.
```
  #!/bin/bash
  # Kill all processes
  docker kill $(docker ps -a -q)
  # Delete all containers
  docker rm $(docker ps -a -q)
  # Delete all images
  docker rmi $(docker images -q)

``` 
# Environment Variables
Both ECS and MOJ implementations use ENV's and [confd](https://github.com/kelseyhightower/confd) during the boostrap process to configure the instance. The following variables are required:

These are for the two web-interface users.
```
  JENKINS_USER_OPGCORE_APITOKEN
  JENKINS_USER_OPGCORE_PASSWORD
  JENKINS_USER_OPGCORE_PUBKEYS
  
  JENKINS_USER_TRAINING_APITOKEN
  JENKINS_USER_TRAINING_PASSWORD
  JENKINS_USER_TRAINING_PUBKEYS
```
Docker authentication variables.
```
  JENKINS_DOCKERCFG_URL
  JENKINS_DOCKERCFG_EMAIL
  JENKINS_DOCKERCFG_USERNAME
  JENKINS_DOCKERCFG_PASSWORD
```
Github SSH keys for checking out repos etc.
```
  JENKINS_GITHUB_PUBKEY
  JENKINS_GITHUB_PRIVKEY
  JENKINS_GITHUB_AUTHKEYS
```
Tweakables for the GIT branch etc, override these in the ```environment.sh```, par exemple:
```
  DEPLOY_GIT_BRANCH=master
  APP_GIT_DOWNSTREAM_BRANCH=
  APP_DOCKER_SUFFIX=dev
  APP_GIT_BRANCH=develop
``` 
## Gotcha
The template for the ```JENKINS_GITHUB_PRIVKEY``` is overwritten by its ```check_cmd```. The reason for this is that private SSH keys require newlines to be embedded in them e.g. ```\n```, however confd (despite it claiming to) doesn't interpret these. So as a workaround
```
  /bin/echo -e $JENKINS_GITHUB_PRIVKEY > {{.src}}
```
is used to correctly set the private key value. Note that the full path is required to echo i.e. ```/bin/echo```, otherwise -e is intepreted as part of the string.
# Amazon ECS
## CloudFormation for Everyone, Everywhere and Always
It is possbile to run the OPG jenkins container on Amazon Web Services without Salt or any other configuration apart from CloudFormation and the environment variables<sup id="a1">[1](#f1)</sup>.

To run a test environment in AWS which creates an ECS cluster of one, with an [Elastic LoadBalancer](https://aws.amazon.com/documentation/elastic-load-balancing/) and [Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) DNS record, run the ```aws.sh``` script. 
```
  ./aws.sh create|update default example.com
```
The script requires a command - either ```create|update``` (to create or update the CloudFormation template), an SSH keyname and DNS domain.

In order to pass the environment variables to the template you will ***also*** need to create an environment.sh file containing the ENV's listed above, thusly,
```
  #!/bin/bash
  JENKINS_DOCKERCFG_PASSWORD=JmiprQPWRVw...
  JENKINS_DOCKERCFG_EMAIL=somebody@example.com
  JENKINS_DOCKERCFG_URL=https://registry.service.example.com/v1/
  JENKINS_DOCKERCFG_USERNAME=somebody
  JENKINS_USER_OPGCORE_APIKEY=JP22DVUEvG...
  JENKINS_USER_OPGCORE_PASSWORD=#jbcrypt:$p9DI0Ubn0C...
  JENKINS_USER_OPGCORE_PUBKEYS=ssh-rsa AAAAB3xRhiVU9VMb7kQfrs70Lusn2zRlL...
  JENKINS_USER_TRAINING_APIKEY=SDJVtCvFUJ...
  JENKINS_USER_TRAINING_PASSWORD=#jbcrypt:$tWTwIL31nE...
  JENKINS_USER_TRAINING_PUBKEYS=ssh-rsa AAAAB3xRhiVU9VMb7kQfrs70Lusn2zRlL...
  JENKINS_GITHUB_PRIVKEY=---PRIVATE...
  JENKINS_GITHUB_PUBKEY=ssh-rsa AAAAB3xRhiVU9VMb7kQfrs70Lusn2zRlL...
  JENKINS_GITHUB_AUTHKEYS=A6:b5:c3:9...
```
##Re-Entrypoint
Because [Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) runs it's own service, the bootstrap sequence has been modified and now consists of a simple bash script that runs all the scripts in ```/etc/my_init.d```.

Quite simply:
```
  #!/bin/bash
  SCRIPTS=/etc/my_init.d/*
  for SCRIPT in $SCRIPTS; do
    if [ -f $SCRIPT -a -x $SCRIPT ]; then
      $SCRIPT
    fi
  done
```
The final command in the ```/etc/my_init.d``` directory can the be set to the jenkins startup script, ```99-run``` in this case, which then starts the container following the bootstrap processes.
#The Documentation Is In The Code, Man...
For more details on how the containers are built see their respective Dockerfiles, and AWS take a gander at the ```aws.sh``` and ```template.json```. Peace and hugs x

---
<sup>1</sup>Thank God[↩](#a1)

