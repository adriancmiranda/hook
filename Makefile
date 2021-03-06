# This Makefile downloads and installs hook dependencies
#
# It depends on GNU Make.
# Tested on Linux (Ubuntu, Gentoo) and Mac OSX.
#
# The default target is "make install", but it also provides "make test" and "make docs".

SHELL := /bin/bash
APIGEN_PATH = ~/Downloads/apigen
CURPATH := $(shell pwd -P)
export PATH=$(HOME)/bin:$(shell echo $$PATH)

default: install

install:
	# check dependencies
ifneq ($(shell which php > /dev/null 2>&1; echo $$?),0)
	$(error "Missing php-cli.")
endif

	# install composer if we don't have it already
ifneq ($(shell which composer > /dev/null 2>&1 || test -x $(HOME)/bin/composer; echo $$?),0)
	mkdir -p $(HOME)/bin
	curl -sS https://getcomposer.org/installer | php -d detect_unicode=Off -- --install-dir=$(HOME)/bin --filename=composer
	chmod +x $(HOME)/bin/composer
endif

	composer install --no-dev --prefer-dist

	@echo "Finished"

test:
	./vendor/bin/phpunit --configuration ./tests/phpunit.xml --testsuite unit
	# DB_DRIVER=mysql ./vendor/bin/phpunit --configuration ./tests/phpunit.xml
	# DB_DRIVER=postgres ./vendor/bin/phpunit --configuration ./tests/phpunit.xml
	# DB_DRIVER=sqlite ./vendor/bin/phpunit --configuration ./tests/phpunit.xml
	# DB_DRIVER=mongodb ./vendor/bin/phpunit --configuration ./tests/phpunit.xml
	# DB_DRIVER=sqlsrv ./vendor/bin/phpunit --configuration ./tests/phpunit.xml

docs:
	mkdir -p ../hook-docs
	rm -rf ../hook-docs/*
	php -d memory_limit=512M ${APIGEN_PATH}/apigen.php --destination ../hook-docs --debug \
																--exclude */tests/* \
																--exclude */Tests/* \
																--source ./src/ \
																--source ./vendor/illuminate \
																--source ./vendor/slim/slim/Slim
	open documentation/index.html
	git init ../hook-docs
	cd ../hook-docs && git remote add origin git@github.com:doubleleft/hook.git && git checkout -b gh-pages && git add .  && git commit -m "update public documentation" && git push origin gh-pages -f
	# --source ./vendor/guzzlehttp/guzzle/src \
