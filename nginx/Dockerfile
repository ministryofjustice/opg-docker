FROM opguk/base:latest

RUN  apt-get update
RUN  apt-get install -y nginx

ADD  docker/nginx /etc/nginx

ADD  docker/service/nginx /etc/service/nginx
RUN  chmod a+x /etc/service/nginx/run

RUN  mkdir -p /app/public
RUN  echo "Hello World from opguk/nginx" > /app/public/index.html

EXPOSE 80
