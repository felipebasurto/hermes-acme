# Compose v4: acme-agent + acme-webui (hermes-webui fork). Override:
# make up DOCKER_COMPOSE="docker compose"
DOCKER_COMPOSE := docker compose

.PHONY: build seed up down setup setup-portal logs logs-webui logs-agent health shell

build:
	$(DOCKER_COMPOSE) build

seed:
	./scripts/seed-volume.sh

up: seed
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down --remove-orphans

setup:
	$(DOCKER_COMPOSE) run --rm acme-agent setup

setup-portal:
	$(DOCKER_COMPOSE) run --rm acme-agent setup --portal

logs:
	$(DOCKER_COMPOSE) logs -f

logs-webui:
	$(DOCKER_COMPOSE) logs -f acme-webui

logs-agent:
	$(DOCKER_COMPOSE) logs -f acme-agent

health:
	./scripts/healthcheck.sh

shell:
	$(DOCKER_COMPOSE) exec acme-agent bash
