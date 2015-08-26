# OPG Jenkins Docker Image
The Jenkins Continuous Integration and Delivery server Dockeri(s|z)ed for the OPG project.
![jenkins_moj_logo](https://cloud.githubusercontent.com/assets/13198078/9408279/47665d26-4809-11e5-9c3f-4113dd3aa07e.png)
# Prerequistes
* An environment.sh file
* [Docker Toolbox](https://www.docker.com/toolbox) - for local MOJ builds
* [aws-cli](http://aws.amazon.com/cli/) - for deploying to Amazon Web Services

## Environment Variables
Both AWS and MOJ implementations use ENV's and [confd](https://github.com/kelseyhightower/confd) during the boostrap process to configure the container. Look at the environment.example file for specifics:
```
  #!/bin/bash
  # A users for logging into the user interface
  JENKINS_USER_OPGCORE_PASSWORD=#jbcrypt:$2a$1...
  JENKINS_USER_OPGCORE_APITOKEN=hbPt5...
  JENKINS_USER_OPGCORE_PUBKEYS=

  JENKINS_USER_TRAINING_PASSWORD=#jbcrypt:$2a$1...
  JENKINS_USER_TRAINING_APITOKEN=sdPCk...
  JENKINS_USER_TRAINING_PUBKEYS=
  
  # Set the user and private Docker registry env's.
  JENKINS_GITHUB_PUBKEY=
  JENKINS_GITHUB_PRIVKEY=
  JENKINS_GITHUB_AUTHKEYS=

  # Git needs to be configured with a user.name and user.email
  GIT_USERNAME=whoami
  GIT_EMAIL_ADDRESS=your.name@address.who

  # Tweakables for setting the branches for building from job
  OPG_CORE_MEMBRANE_BRANCH=develop
  OPG_CORE_FRONT_END_BRANCH=develop
  OPG_CORE_BACK_END_BRANCH=develop

  # Set the downstream branch to merge to
  # and the docker tag suffix
  DOWNSTREAM_BRANCH=
  DOCKER_SUFFIX=dev
```
as you will need to set these before you run either of the two deployments.

## Docker Toolbox
To run locally use [Docker Toolbox](https://www.docker.com/toolbox)

If you're feeling lucky run, 
```
  docker-compose up -d
```  
which creates the Jenkins container and daemonizes it. 

Connect to Jenkins on:
```
  curl http://$(docker-machine ip default):8080
```

### Baking
This [docker](https://www.docker.com/) build environment contains two possible containers.

1. [MOJ](https://www.youtube.com/watch?v=nr90nbqxuZk) docker container
2. [Amazon](http://www.sheppardsoftware.com/images/South%20America/factfile/Amazon_Rainforest.jpg) ECS docker container

The reason being two, is that Amazon ECS runs it's own service (like [my_init and runit](https://github.com/phusion/baseimage-docker) from our base container) which cleans up [zombie](http://3.bp.blogspot.com/-LE9q0n6-hKg/TqQI-NneSzI/AAAAAAAAAYs/a0GpdT5aBHE/s1600/npc_44_fat_zombie.png) processes and respawns the entrypoint. Hence if the entrypoint is ```/sbin/my_init```, (as in the MOJ containers) it will run this and kill the runit process stopping the container. At which point it will start ```/sbin/my_init``` again, and so on...

To make the MOJ container image run
```
  make TAG=moj
```
and the Amazon container
```
  make TAG=ecs
```

### Testing, Tagging, releasing, pushing, cleaning...
Check out the ```Makefile``` for further details. For instance if you want to nuke your docker builds and cleanup your computer of all docker containers and images, run the ```make clean``` which is just
```
  #!/bin/bash
  # Kill all processes
  docker kill $(docker ps -a -q)
  # Delete all containers
  docker rm $(docker ps -a -q)
  # Delete all images
  docker rmi $(docker images -q)
``` 
## Amazon ECS
### CloudFormation for Everyone, Everywhere and Always
It is possbile to run the OPG jenkins container on Amazon Web Services without Salt or any other configuration apart from CloudFormation and the environment variables<sup id="a1">[1](#f1)</sup>.

To run a test environment in AWS which creates an ECS cluster of one, with an [Elastic LoadBalancer](https://aws.amazon.com/documentation/elastic-load-balancing/) and [Route53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) DNS record, run the ```aws``` script. 
```
  ./aws create|update MyBestistSshKey example.com
```
The script requires a command - either ```create|update``` (to create or update the CloudFormation template), an SSH keyname and DNS domain.

In order to pass the environment variables to the template you will ***also*** need to create an environment.sh file containing the ENV's listed above. At a minimum you must configure the following,
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
  <b>greenballs</b>
```
and then run your make command. 

# The Documentation Is In The Code

For more details on how the containers are built see their respective Dockerfiles, and AWS take a gander at the ```aws``` script and ```template.json```.

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
<sup>1</sup>Thank God[↩](#a1)</br>

