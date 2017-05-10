FROM registry.service.opg.digital/opguk/base0x644

ADD docker/bin/compile_nginx.sh /tmp/compile_nginx.sh
RUN sh /tmp/compile_nginx.sh

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
