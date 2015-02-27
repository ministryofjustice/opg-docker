FROM opguk/nginx:latest

#ruby version: 2.2.0

WORKDIR root
RUN  apt-get update && apt-get -y upgrade && \
     apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev && \
     apt-get install -y libyaml-0-2 libxslt1.1 libpq5 && \
     apt-get autoclean && apt-get autoremove && rm -rf /var/lib/{apt,dpkg,cache,log}/ && rm -rf /tmp/* /var/tmp/*

RUN  curl http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.gz | tar -xz && \
     cd ruby-2.2.0 && ./configure --prefix= && make -j 4 && make install && \
     rm -Rf ruby-2.2.0

RUN  gem install bundler

#example ruby web app
RUN  gem install sinatra
ADD  docker/nginx /etc/nginx
ADD  docker/service/app /etc/service/app
RUN  chmod a+x /etc/service/app/run

RUN  mkdir -p /app/public
ADD  src/hello.rb /app/hello.rb
WORKDIR app

ADD  docker/beaver.d /etc/beaver.d
