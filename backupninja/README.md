opguk/backupninja
=================

Basic Backupninja/Duplicity setup to use as a base for containers requiring backup functionality.

Supported variables
-------------------

* BACKUPNINJA_BASEDIR - Location for Backupninja to use for backup files (e.g.: `/data/backup`)
* BACKUPNINJA_DUPLICITY_PASSWORD - Password to be used for Duplicity
* BACKUPNINJA_DUPLICITY_AWS_KEY - AWS key to use for accessing S3 bucket (e.g.: `AKIAIOSFODNN7EXAMPLE`)
* BACKUPNINJA_DUPLICITY_AWS_SECRET - AWS secret to use for accessing S3 bucket (e.g.: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
* BACKUPNINJA_DUPLICITY_ENABLED - Defines if backups will run (e.g.: `True`)
* BACKUPNINJA_DUPLICITY_KEEP - How many days to keep daily backups (e.g.: `60`)
* BACKUPNINJA_DUPLICITY_DESTURL - The location to store daily backups (e.g.: `s3://s3-eu-west-1.amazonaws.com/backupninja/example/daily`)
* BACKUPNINJA_DUPLICITY_HOURLY_ENABLED - Defines if hourly backups will run (e.g.: `False`)
* BACKUPNINJA_DUPLICITY_HOURLY_KEEP - How many days to keep hourly backups (e.g.: `60`)
* BACKUPNINJA_DUPLICITY_HOURLY_DESTURL - The location to store hourly backups (e.g.: `s3://s3-eu-west-1.amazonaws.com/backupninja/example/hourly`)
* BACKUPNINJA_DUPLICITY_HOURLY_INCLUDE_1 - Files to specifically include in hourly backups
* BACKUPNINJA_DUPLICITY_HOURLY_INCLUDE_2 - ...
* BACKUPNINJA_DUPLICITY_HOURLY_INCLUDE_3 - ... etc.
* BACKUPNINJA_DUPLICITY_HOURLY_EXCLUDE_1 - Files to specifically exclude from hourly backups
* BACKUPNINJA_DUPLICITY_HOURLY_EXCLUDE_2 - ...
* BACKUPNINJA_DUPLICITY_HOURLY_EXCLUDE_3 - ... etc.
