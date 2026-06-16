# Compose v2 (el plugin moderno). v3 requiere `build` y docker-compose v1 no es
# compatible con Docker Engine 29. Override: make up DOCKER_COMPOSE="docker compose"
DOCKER_COMPOSE := docker compose

.PHONY: build seed up down setup setup-portal logs health shell

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

health:
	./scripts/healthcheck.sh

shell:
	$(DOCKER_COMPOSE) exec acme-agent bash
