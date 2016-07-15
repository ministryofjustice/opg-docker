as abstract as possible nginx setup

env vars
--------
- OPG_NGINX_SSL_FORCE_REDIRECT - if set then container will redirect all `http` traffic to `https`
- OPG_NGINX_INDEX - set a custom index document, defaults to 'index.html' if unset
- OPG_NGINX_ROOT - set a custom root path, defaults to '/app/public' if unset
