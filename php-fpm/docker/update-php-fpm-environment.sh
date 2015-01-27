#!/bin/sh

echo "Updating app.conf with all environment variables"

env | awk -F = '{print "env[" $1 "]", "=", "\"" $2 "\""}' >> /etc/php5/fpm/pool.d/app.conf
