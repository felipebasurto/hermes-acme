DOCKER_COMPOSE := /opt/homebrew/bin/docker-compose

.PHONY: seed up down setup setup-portal logs health shell

seed:
	./scripts/seed-volume.sh

up: seed
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

setup:
	$(DOCKER_COMPOSE) run --rm acme-hermes setup

setup-portal:
	$(DOCKER_COMPOSE) run --rm acme-hermes setup --portal

logs:
	$(DOCKER_COMPOSE) logs -f

health:
	./scripts/healthcheck.sh

shell:
	$(DOCKER_COMPOSE) exec acme-hermes bash
