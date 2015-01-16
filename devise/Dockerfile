FROM opguk/ruby:latest


ADD  docker/nginx /etc/nginx
ADD  docker/service/app /etc/service/app
RUN  chmod a+x /etc/service/app/run

ADD  mongoid.yml /app/config/mongoid.yml

ADD  vendor/devise_authentication_api/Gemfile /app/Gemfile
ADD  Gemfile.lock /app/Gemfile.lock

WORKDIR /app
USER app
ENV  HOME /app
RUN  bundle install --deployment --without test

ADD  vendor/devise_authentication_api /app
ADD  vendor/opg-core-devise-mailer-templates /app/views/devise/mailer/
ADD  Gemfile.lock /app/Gemfile.lock

USER root
RUN  chown -R app:app /app
