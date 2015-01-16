FROM opguk/nginx:latest

#ruby version: 2.2.0

WORKDIR root
RUN  apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
RUN  curl http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.gz | tar -xz
RUN  cd ruby-2.2.0 && ./configure --prefix= && make && make install
RUN  rm -Rf ruby-2.2.0

RUN  gem install bundler

#example ruby web app
RUN  gem install sinatra
ADD  docker/nginx /etc/nginx
ADD  docker/service/app /etc/service/app
RUN  chmod a+x /etc/service/app/run

RUN  mkdir -p /app/public
ADD  src/hello.rb /app/hello.rb
WORKDIR app
