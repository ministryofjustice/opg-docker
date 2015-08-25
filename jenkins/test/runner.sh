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
ID=`docker run -d -p 8080:8080 -v ./test:/test $NAME:$VERSION /sbin/my_init`
sleep 1

#trap cleanup EXIT

echo " --> Running tests"