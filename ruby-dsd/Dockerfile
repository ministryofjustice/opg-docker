FROM opguk/nginx:latest

#ruby version: dsd

WORKDIR root
RUN  apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

RUN echo "deb [arch=amd64] http://repo.dsd.io trusty main" > /etc/apt/sources.list.d/dsd.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6929455C
RUN apt-get update

RUN apt-get install -y --no-install-recommends dsd-ruby2.1-bundler libyaml-0-2 libxslt1.1 libpq5

#RUN  gem install bundler

#example ruby web app
RUN  gem install sinatra
ADD  docker/nginx /etc/nginx
ADD  docker/service/app /etc/service/app
RUN  chmod a+x /etc/service/app/run

RUN  mkdir -p /app/public
ADD  src/hello.rb /app/hello.rb
WORKDIR app
