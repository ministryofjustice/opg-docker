base docker image that:
- ensures latest ubuntu
- creates application skeleton

directory structure:
```
/app - directory to install app (owned by app user)
/data - directory to store data (might be available as a mounted volume)
/var/run/app - for pid/sock files
/var/log/app - for all application logs
```

versions are in date format
i.e:
opg/base:2014.01.13
