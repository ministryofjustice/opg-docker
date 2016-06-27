#!/bin/bash

#status=`|grep "status"`
#
#echo "Status is ${status}"
i=0

while [ $i -lt 10 ]
do
now=`date`
echo "Timestamp is ${now}"
curl -XGET "http://localhost:9200/_cluster/health?pretty=true"
sleep 10
i=$[$i+1]
done