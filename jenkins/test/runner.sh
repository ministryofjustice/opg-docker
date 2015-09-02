#!/bin/bash
set -e

function abort()
{
	echo "$@"
	exit 1
}

function cleanup()
{
	echo " --> Stopping container"
	docker stop $ID >/dev/null
	docker rm $ID >/dev/null
}

PWD=`pwd`

echo " --> Starting container"
ID=`docker run -d -p 8080:8080 -v $PWD/test:/test $NAME:$VERSION /sbin/my_init`
sleep 1

echo " --> Verifying container"
docker ps -q | grep ^${ID:0:12} > /dev/null
if [ $? -ne 0 ]; then
	abort "Unable to verify container IP"
else
  echo " --> Container verifyied"
fi

trap cleanup EXIT

echo " --> Running tests"

echo " --> Checking Jenkins process"
sleep 10
docker exec -it $ID ps -ef | grep jenkins > /dev/null
if [ $? -ne 0 ]; then
	abort "No Jenkins Process running"
else
  echo " --> Jenkins is running"
fi

echo " --> Checking HTTP port 8080, please wait"
sleep 30
curl -s http://$(docker-machine ip default):8080 > /dev/null

if [ $? -ne 0 ]; then
	abort "Jenkins is not open on 8080"
else
  echo " --> Connected on port 8080"
fi




