# OPG Jenkins Docker Image
The Jenkins Continuous Integration and Delivery server Dockeri(s|z)ed for the OPG project.
![jenkins_moj_logo](https://cloud.githubusercontent.com/assets/13198078/9408279/47665d26-4809-11e5-9c3f-4113dd3aa07e.png)
# Prerequistes
* An environment.sh file
* [boot2docker](http://boot2docker.io/) && docker-compose - for local builds
* [aws-cli:](http://aws.amazon.com/cli/) for deploying to Amazon Web Services

## Environment Variables
Both ECS and MOJ implementations use ENV's and [confd](https://github.com/kelseyhightower/confd) during the boostrap process to configure the instance. Look at the environment.example file for specifics,
```
  #!/bin/bash
  # Set the user and private Docker registry env's.
  JENKINS_GITHUB_PUBKEY=
  JENKINS_GITHUB_PRIVKEY=
  JENKINS_GITHUB_AUTHKEYS=

  # These are users for logging into the user interface
  JENKINS_USER_OPGCORE_APITOKEN=
  JENKINS_USER_OPGCORE_PASSWORD=
  JENKINS_USER_OPGCORE_PUBKEYS=

  # Git needs to be configured with a user.name and user.email
  GIT_USERNAME=whoami
  GIT_EMAIL_ADDRESS=your.name@address.who

  # Tweakables for setting the branches from the first build job
  OPG_MEMBRANE_BRANCH=develop
  OPG_FRONTEND_BRANCH=develop
  OPG_BACKEND_BRANCH=develop

  # Legacy variables that were used to deploy 
  # on the salt version of Jenkins
  # DEPLOY_GIT_BRANCH=master
  # APP_GIT_DOWNSTREAM_BRANCH=
  # APP_DOCKER_SUFFIX=dev
  # APP_GIT_BRANCH=develop
```
as you will need to set these before you run either of the two deployments.

## boot2docker
To run locally use [boot2docker](http://boot2docker.io/)<sup id="a1">[1](#f1)</sup>

If you're feeling lucky run, 
```
  ./boot2docker
```
(you will need to configure an environment file though). The main command to note is:
```
  docker-compose up -d
```  
which creates the containers and daemonizes them. 

Connect to Jenkins on:
```
  curl http://$(boot2docker ip):8080
```

### Baking
This [docker](https://www.docker.com/) build environment contains two possible containers.

1. [MOJ](https://www.youtube.com/watch?v=nr90nbqxuZk) docker container
2. [Amazon](http://www.sheppardsoftware.com/images/South%20America/factfile/Amazon_Rainforest.jpg) ECS docker container

The reason being two, is that Amazon ECS runs it's own service (like [my_init and runit](https://github.com/phusion/baseimage-docker) from our base container) which cleans up [zombie](http://3.bp.blogspot.com/-LE9q0n6-hKg/TqQI-NneSzI/AAAAAAAAAYs/a0GpdT5aBHE/s1600/npc_44_fat_zombie.png) processes and respawns the entrypoint. Hence if the entrypoint is ```/sbin/my_init```, (as in the MOJ containers) it will run this and kill the runit process stopping the container. At which point it will start ```/sbin/my_init``` again, and so on...

To make the MOJ container image run
```
  make
```
and the Amazon container
```
  make -f Makefile-moj
```

### Pushing
Push the image to our registry if required, you will have to do this if using Amazon:
```
  docker push registry.service.dsd.io/opguk/jenkins-ecs
```

## Amazon ECS
### CloudFormation for Everyone, Everywhere and Always
It is possbile to run the OPG jenkins container on Amazon Web Services without Salt or any other configuration apart from CloudFormation and the environment variables<sup id="a2">[2](#f2)</sup>.

To run a test environment in AWS which creates an ECS cluster of one, with an [Elastic LoadBalancer](https://aws.amazon.com/documentation/elastic-load-balancing/) and [Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) DNS record, run the ```aws``` script. 
```
  ./aws create|update MyBestistSshKey example.com
```
The script requires a command - either ```create|update``` (to create or update the CloudFormation template), an SSH keyname and DNS domain.

In order to pass the environment variables to the template you will ***also*** need to create an environment.sh file containing the ENV's listed above, At a minimum you must configure the following thusly,
```
  #!/bin/bash
  JENKINS_USER_TRAINING_APIKEY=JP22DVUEvG...
  JENKINS_USER_TRAINING_PASSWORD=#jbcrypt:$p9DI0Ubn0C...
  JENKINS_USER_TRAINING_PUBKEYS=ssh-rsa AAAAB3xRhiVU9VMb7kQfrs70Lusn2zRlL...
  JENKINS_GITHUB_PRIVKEY=---PRIVATE...
  JENKINS_GITHUB_PUBKEY=ssh-rsa AAAAB3xRhiVU9VMb7kQfrs70Lusn2zRlL...
  JENKINS_GITHUB_AUTHKEYS=A6:b5:c3:9...
  GIT_USERNAME=jonathan.wicks@...
  GIT_EMAIL_ADDRESS=bad.ass@killyou...
  OPG_MEMBRANE_BRANCH=training
  OPG_FRONTEND_BRANCH=training
  OPG_BACKEND_BRANCH=training
```

# Customising Your Container
## Plugins
Jenkins plugins are installed via a script, you can configure the plugins that you want to be installed by editing the 
```
  usr/share/jenkins/ref/plugins.txt
```
file, so to install the *greenballs* plugin you would simply add-edit the file, like so,
```
  ...
  xunit
  plain-credentials
  workflow-step-api
  ***greenballs***
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

# The Documentation Is In The Code, Man...

For more details on how the containers are built see their respective Dockerfiles, and AWS take a gander at the ```aws``` and ```template.json```.
---
# Appendix
## Gotcha
The template for the ```JENKINS_GITHUB_PRIVKEY``` is overwritten by its ```check_cmd```. The reason for this is that private SSH keys require newlines to be embedded in them e.g. ```\n```, however confd (despite it claiming to) doesn't interpret these. So as a workaround
```
  /bin/echo -e $JENKINS_GITHUB_PRIVKEY > {{.src}}
```
is used to correctly set the private key value. Note that the full path is required to echo i.e. ```/bin/echo```, otherwise -e is intepreted as part of the string - haha Gotcha!

## Re-Entrypoint
Because [Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) runs it's own service, the bootstrap sequence our base image employs has been modified, and now consists of a simple bash script that runs all the scripts in ```/etc/my_init.d```.

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
---
<sup>1</sup>You could upgrade to the [Docker Toolbox](https://www.docker.com/toolbox), but it isn't necessary[↩](#a1)</br>
<sup>2</sup>Thank God[↩](#a2)

