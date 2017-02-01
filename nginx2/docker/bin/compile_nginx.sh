#!/bin/bash
useradd -r nginx
mkdir -p /var/lib/nginx && chown nginx:nginx /var/lib/nginx
mkdir -p /var/log/nginx && chown nginx:nginx /var/log/nginx
cd  /tmp
git clone https://github.com/newobj/nginx-x-rid-header.git
wget http://nginx.org/download/nginx-1.9.5.tar.gz
tar -xzf nginx-1.9.5.tar.gz
cd nginx-1.9.5
./configure \
  --user=nginx \
  --group=nginx \
  --prefix=/etc/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --sbin-path=/usr/sbin/nginx \
  --error-log-path=/var/log/nginx/error.log \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-log-path=/var/log/nginx/access.log \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --lock-path=/var/lock/nginx.lock \
  --pid-path=/var/run/nginx.pid \
  --with-http_gzip_static_module \
  --with-http_stub_status_module \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-pcre-jit \
  --with-ipv6 \
  --add-module=../nginx-x-rid-header --with-ld-opt=-lossp-uuid --with-cc-opt=-I/usr/include/ossp
make
make install
