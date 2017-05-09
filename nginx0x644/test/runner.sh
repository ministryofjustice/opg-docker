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
ID=`docker run -d -p 80:80 -p 443:443 -v $PWD/test:/test $NAME:$VERSION /sbin/my_init`
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

echo " --> Checking Nginx process"
docker exec -it $ID ps -ef | grep nginx > /dev/null
if [ $? -ne 0 ]; then
	abort "No Nginx Process running"
else
  echo " --> Nginx is running"
fi

echo " --> Checking HTTP port 443, please wait"
curl -s -k https://$(docker-machine ip default) | grep "Hello World from opguk/nginx" > /dev/null

if [ $? -ne 0 ]; then
	abort "Nginx is not open on 443"
else
  echo " --> Connected on port 443"
fi

echo " --> Checking for X-Request-Id header"
curl -I -k -s https://$(docker-machine ip default) | grep "X-Request-Id" > /dev/null

if [ $? -ne 0 ]; then
	abort "Nginx is not creating a X-Request-Id header"
else
  echo " --> X-Request-Id header found"
fi
