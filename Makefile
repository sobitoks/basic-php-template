#!/bin/bash

UID ?= $(shell id -u)
GID ?= $(shell id -g)
DOCKER_APP = bpt_app

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

copy-dist-configs:
	if [ -e docker-compose.yml.dist ]; then cp -n docker-compose.yml.dist docker-compose.yml; fi
	if [ -e .env.dist ]; then cp -n .env.dist .env; fi


### DEV ###
### /DEV ###

build:
	$(MAKE) copy-dist-configs
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml build

build-dev: ## It might install xdebug if you set the right env vars
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml build

build-dev-with-xdebug:
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) build-dev

start: ## Start the containers
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml up -d

start-dev:
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml up -d

start-dev-xdebug:
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) start-dev

start-dev-build:
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml up -d --build

start-dev-build-xdebug:
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) start-dev-build

stop: ## Stop the containers
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml stop

stop-dev:
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml stop

restart: ## Restart the containers with the flag --build
	$(MAKE) stop && $(MAKE) start

restart-dev:
	$(MAKE) stop-dev && $(MAKE) start-dev

restart-dev-build:
	$(MAKE) stop-dev && $(MAKE) start-dev-build

ssh-app: ## sh into the be container
	U_ID=${UID} G_ID=${GID} docker exec -it --user ${UID} ${DOCKER_APP} sh

cs: ## Runs php-cs to fix code styling following Symfony rules
	U_ID=${UID} G_ID=${GID} docker exec -it --user ${UID} ${DOCKER_APP} php-cs-fixer fix src --rules=@Symfony
