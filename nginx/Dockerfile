FROM registry.service.dsd.io/opguk/base:latest

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y libpcre3-dev zlib1g-dev libssl-dev libossp-uuid-dev uuid && \
     apt-get clean && apt-get autoremove && \
     rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/*

ADD docker/bin/compile_nginx.sh /tmp/compile_nginx.sh
RUN chmod +x /tmp/compile_nginx.sh
RUN /tmp/compile_nginx.sh

ADD  docker/nginx /etc/nginx
ADD  docker/confd /etc/confd

ADD  docker/service/nginx /etc/sv/nginx
RUN  chmod a+x /etc/sv/nginx/run && \
     ln -s /etc/sv/nginx /etc/service/

RUN  mkdir -p /app/public /etc/nginx/app.conf.d && \
     echo "Hello World from opguk/nginx" > /app/public/index.html

EXPOSE 80
EXPOSE 443

ENV OPG_SERVICE nginx
