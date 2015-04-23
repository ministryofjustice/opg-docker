opguk/base
==========
Base docker image that:
- ensures latest ubuntu
- creates application skeleton
- creates log shipping skeleton


structure
---------
directory structure:
```
/app - directory to install app (owned by app user)
/data - directory to store data (might be available as a mounted volume)
/var/run/app - for pid/sock files
/var/log/app - for all application logs
```


log shipping
------------
It ships logs using beaver that will only start if:
- monitoring box is linked (monitoring `hostname` is available in /etc/hosts)
- or variable MONITORING_ENABLED is set.
Logs are shipped to redis on `monitoring` host.
All inheriting containers should add their respective beaver config file to /etc/beaver.d/(change_me).conf


versions
--------
Versions are in reduced semver (because docker don't support build segment):
i.e:
opg/base:0.0.2

If OPG_DOCKER_TAG env variable will be passed to the container then it will generate /app/META file with {'rev': '$OPG_DOCKER_TAG'}


supported variables
-------------------
OPG_DOCKER_TAG - see versions


TODO
----
Configure syslog shipping
Solve logrotation as we don't want dockers to leak disk usage
