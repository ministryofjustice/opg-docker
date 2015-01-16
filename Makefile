.PHONY: build

build:
	cd base && make
	cd nginx && make
	cd php-fpm && make
	cd ruby && make
	cd devise && make

push:
	docker push opguk/base
	docker push opguk/nginx
	docker push opguk/php-fpm
	docker push opguk/ruby
	docker push opguk/devise
