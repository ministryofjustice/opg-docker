opguk/casperjs
==============

A simple casperjs/phantomjs container to run functional testing

Example usage
-------------

Usage of this container is best demonstrated in [the opg-lpa-deploy repo](https://github.com/ministryofjustice/opg-lpa-deploy/tree/master/test/casper).

Running a `make test` for example, will call the following line in the Makefile:

```
docker run --net=host --rm -it -v `pwd`:/mnt/test $(NAME):$(VERSION) /mnt/test/start.sh 'tests/${suite}'
```

This calls the testing script which utimately runs casperjs against the testing files that you provide:

```
/usr/local/bin/casperjs test /mnt/test/$1 --ignore-ssl-errors=true --ssl-protocol=tlsv1 --includes=/mnt/test/config/Bootstrap.js
```
