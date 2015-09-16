A container to route traffic to selected linked containers.


Example ENV variables:
```
OPG_NGINX_ROUTER_00_VHOST = www.*
OPG_NGINX_ROUTER_00_TARGET = http://phpapp
OPG_NGINX_ROUTER_00_CLIENT_MAX_BODY_SIZE = 20M

OPG_NGINX_ROUTER_01_VHOST = kibana.*
OPG_NGINX_ROUTER_01_TARGET = http://kibana
```

In example above nginx will default to the 1st host if vhost is not matched
