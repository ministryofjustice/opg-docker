FROM registry.service.dsd.io/opguk/base:latest

RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y nginx && \
     apt-get autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}/ && rm -rf /tmp/* /var/tmp/*


ADD  docker/nginx /etc/nginx

ADD  docker/service/nginx /etc/service/nginx
RUN  chmod a+x /etc/service/nginx/run

RUN  mkdir -p /app/public
RUN  echo "Hello World from opguk/nginx" > /app/public/index.html

ADD  docker/beaver.d /etc/beaver.d


EXPOSE 80
