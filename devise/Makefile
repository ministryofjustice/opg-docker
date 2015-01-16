.PHONY: build


build: vendor/devise_authentication_api vendor/opg-core-devise-mailer-templates
	docker build -t "opguk/devise:latest" .


vendor/devise_authentication_api:
	mkdir -p vendor
	cd vendor && git clone git@github.com:ministryofjustice/devise_authentication_api.git


vendor/opg-core-devise-mailer-templates:
	mkdir -p vendor
	cd vendor && git clone git@github.com:ministryofjustice/opg-core-devise-mailer-templates.git


