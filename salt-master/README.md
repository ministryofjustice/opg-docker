# salt-master

CURRENTLY FOR DEV PURPOSES ONLY AS THROWN TOGETHER IN ABOUT 30 MINUTES

Feel free to sex it up

```
my_init.d/00-accept-keys  (wait for salt master to start then accept all keys)
my_init.d/00-update-hosts (update /etc/hosts localhost entry to add "salt")
```

Created a simple top.sls with a single simple base formula that ensures a few packages are installed. Kept simple
just to allow a highstate to be run so additional formula/pillar data can be developed/tested

```
root@b87a73bd5c39:/# cat /srv/salt/_libs/base/packages.sls
base_pkgs:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - vim
root@b87a73bd5c39:/#
```

### Pillar Roots

We can add pillar roots to the salt config, these store common information for states

In the local machine example they are added to `/srv/common`, we have two state files that are not applied by default, but can be called to
install the data from pillar roots

If we run a highstate using either of these the data is read from the pillar root to apply to the states

```bash

$  salt '*' state.apply apache
cd5539d91a53:
----------
          ID: apache
    Function: pkg.installed
        Name: apache2
      Result: True
     Comment: The following packages were installed/updated: apache2
     Started: 10:36:50.275616
    Duration: 13570.585 ms
     Changes:
              ----------
              apache2:
                  ----------
                  new:
                      2.4.7-1ubuntu4.10
                  old:
              apache2-api-20120211:
                  ----------
                  new:
                      1
                  old:
              apache2-bin:
                  ----------
                  new:
                      2.4.7-1ubuntu4.10
                  old:
              apache2-data:
                  ----------
                  new:
                      2.4.7-1ubuntu4.10
                  old:
              httpd:
                  ----------
                  new:
                      1
                  old:
              httpd-cgi:
                  ----------
                  new:
                      1
                  old:
              libapr1:
                  ----------
                  new:
                      1.5.0-1
                  old:
              libaprutil1:
                  ----------
                  new:
                      1.5.3-1
                  old:
              libaprutil1-dbd-sqlite3:
                  ----------
                  new:
                      1.5.3-1
                  old:
              libaprutil1-ldap:
                  ----------
                  new:
                      1.5.3-1
                  old:
              libxml2:
                  ----------
                  new:
                      2.9.1+dfsg1-3ubuntu4.7
                  old:
              sgml-base:
                  ----------
                  new:
                      1.26+nmu4ubuntu1
                  old:
              ssl-cert:
                  ----------
                  new:
                      1.0.33
                  old:
              xml-core:
                  ----------
                  new:
                      0.13+nmu2
                  old:

```

### Custom reactor example

These are badly documented, however what is missing in the docs is the following
If you are going to use a custom namespace these cannot be wildcarded, if you want to
use wild cards and matching it seems they need to go into the `salt/custom` namespace

See examples in reactor_templates and salt_master.conf.tmpl

To test them...

```bash

$ salt-call event.send 'salt/custom/start_highstate'

#A call to jobs.list_jobs

$ salt-run jobs.list_jobs
  ...#Output
  20160520143647697134:
    ----------
    Arguments:
        - salt/custom/start_highstate
    Function:
        event.send
    StartTime:
        2016, May 20 14:36:47.697134
    Target:
        e4c55b2205dd
    Target-type:
        glob
    User:
        root
  20160520143647722175:
    ----------
    Arguments:
    Function:
        state.highstate
    StartTime:
        2016, May 20 14:36:47.722175
    Target:
        *
    Target-type:
        glob
    User:
        root
```
