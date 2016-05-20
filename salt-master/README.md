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

### Custom reactor example

These are badly documented, however what is missing in the docs is the following
If you are going to use a custom namespace these cannot be wildcarded, if you want to
use wild cards and matching it seems they need to go into the `salt/custom` namespace

See examples in reactor_templates and salt_master.conf.tmpl