Nginx with http2 support
------------------------

As abstract as possible nginx setup. there is a default catchall which will return status 444 if no matching host header is found.

**Note:**

ALPN support is not available at this stage, so browers which do not support NLN negotiation

env vars
--------
- OPG_NGINX_SSL_FORCE_REDIRECT - if set then container will redirect all `http` traffic to `https`
- OPG_NGINX_INDEX - set a custom index document, defaults to 'index.html' if unset
- OPG_NGINX_ROOT - set a custom root path, defaults to '/app/public' if unset
- OPG_NGINX_SERVER_NAMES - used to populate server_name directive. **This must be provided at runtime**
- OPG_NGINX_HOST_IP - ip address of the docker host **this is required if you deploy behind a load balancer(ELB)**

