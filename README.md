# opg-docker

Q&A
---

Why does every service creates /var/log structure at runtime?

I't quite common that developer will run the container and mount /var/log
So make sure that every service started will pre-create its log directory structure on start time.
Instead of relying on RUN directives to do so.



How to run application as specific user? Shall I use `su foo -c "ls"`?

It's recommended to use setuser.
i.e. `exec /sbin/setuser memcache /usr/bin/memcached`


prerequisites
-------------
- docker
- make
- semvertag (https://github.com/ministryofjustice/semvertag)


TODO
----
pick something to generate config files
