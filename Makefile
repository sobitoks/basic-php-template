#!/bin/bash

UID ?= $(shell id -u)
GID ?= $(shell id -g)
DOCKER_APP = bpt_app

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

### <PRD BUILD> ###
prepare: ## Up and running
	$(MAKE) build
	$(MAKE) start

build: ## Build the image
	$(MAKE) copy-dist-configs
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml build

start: ## Start the containers
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml up -d

restart: ## Restart the containers
	$(MAKE) stop && $(MAKE) start

stop: ## Stop the containers
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.yaml stop

### </PRD BUILD> ###

### <DEV BUILD> ###
prepare-dev: ## Up and running dev
	$(MAKE) stop-dev
	$(MAKE) build-dev
	$(MAKE) start-dev
	$(MAKE) composer-install

build-dev: ## It might install xdebug if you set the right env vars
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml build

start-dev: ## you name it
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml up -d

start-dev-build: ## you name it
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml up -d --build

restart-dev: ## you name it
	$(MAKE) stop-dev && $(MAKE) start-dev

restart-dev-build: ## you name it
	$(MAKE) stop-dev && $(MAKE) start-dev-build

stop-dev: ## you name it
	U_ID=${UID} G_ID=${GID} docker compose -f docker-compose.dev.yaml stop
### </DEV BUILD> ###

### <DEV XDEBUG BUILD> ###
prepare-dev-xdebug: ## Up and running dev
	$(MAKE) stop-dev
	$(MAKE) build-dev-xdebug
	$(MAKE) start-dev-xdebug
	$(MAKE) composer-install

build-dev-xdebug: ## you name it
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) build-dev

start-dev-xdebug: ## you name it
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) start-dev

start-dev-build-xdebug: ## you name it
	XDEBUG_MODE=debug BUILD_TARGET=app_dev $(MAKE) start-dev-build

restart-dev-xdebug: ## you name it
	$(MAKE) stop-dev && $(MAKE) start-dev-xdebug

restart-dev-build-xdebug: ## you name it
	$(MAKE) stop-dev && $(MAKE) start-dev-build-xdebug
### </DEV XDEBUG BUILD> ###

### <COMMON> ###
copy-dist-configs: ## you name it
	if [ -e docker-compose.yml.dist ]; then cp -n docker-compose.yml.dist docker-compose.yml; fi
	if [ -e .env.dist ]; then cp -n .env.dist .env; fi

composer-install: ## Installs composer dependencies
	U_ID=${UID} docker exec --user ${UID} -it ${DOCKER_APP} composer install --no-interaction

app-logs: ## Tails the Symfony dev log
	U_ID=${UID} docker exec -it --user ${UID} ${DOCKER_APP} tail -f var/log/dev.log

ssh-app: ## sh into the be container
	U_ID=${UID} G_ID=${GID} docker exec -it --user ${UID} ${DOCKER_APP} sh

cs: ## Runs php-cs to fix code styling following Symfony rules
	U_ID=${UID} G_ID=${GID} docker exec -it --user ${UID} ${DOCKER_APP} php-cs-fixer fix src --rules=@Symfony
### </COMMON> ###