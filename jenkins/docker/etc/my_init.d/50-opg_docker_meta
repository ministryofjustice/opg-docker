#!/bin/sh

if [ -n "${OPG_DOCKER_TAG}" ]
then
    echo "Generating /app/META"
    echo "{\"rev\":\"${OPG_DOCKER_TAG}\"}" > /app/META
else
    echo "Skipping /app/META - OPG_DOCKER_TAG is not set"
fi
