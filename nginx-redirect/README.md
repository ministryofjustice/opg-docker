nginx-redirect
==============

Container to redirect to new location

env variables
-------------
* OPG_NGINX_SSL_FORCE_REDIRECT: forces use of HTTPS (from nginx container)  
* OPG_NGINX_REDIRECT_URL: location to redirect to  (requires protocol and no trailing slash e.g. `https://www.google.com`)
* OPG_NGINX_REDIRECT_DROPPATH: if set will redirect to only the URL specified in OPG_NGINX_REDIRECT_URL with no additional path preserved

