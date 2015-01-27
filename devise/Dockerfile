FROM opguk/ruby:latest


ADD  vendor/devise_authentication_api/Gemfile /app/Gemfile
ADD  Gemfile.lock /app/Gemfile.lock

WORKDIR /app
USER app
ENV  HOME /app
RUN  bundle install --deployment --without test

ADD  vendor/devise_authentication_api /app
ADD  vendor/opg-core-devise-mailer-templates /app/views/devise/mailer/
ADD  Gemfile.lock /app/Gemfile.lock

ADD  mongoid.yml /app/config/mongoid.yml

USER root
RUN  chown -R app:app /app

RUN  apt-get install -y mongodb-clients

ADD  docker/nginx /etc/nginx
ADD  docker/service/app /etc/service/app
RUN  chmod a+x /etc/service/app/run
