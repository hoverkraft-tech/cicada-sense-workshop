# Makefile for Cicada Sense.
# Root commands orchestrate Docker Compose only; Node tooling lives inside app containers.

.PHONY: help install setup build up down logs shell lint lint-fix typecheck test docs-check ci helm clean

MAKEFLAGS += --silent
.DEFAULT_GOAL := help

LOCAL_UID := $(shell id -u)
LOCAL_GID := $(shell id -g)
COMPOSE := LOCAL_UID=$(LOCAL_UID) LOCAL_GID=$(LOCAL_GID) COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose
APP_RUN = $(COMPOSE) run --rm -T --no-deps --remove-orphans
APP_SERVICES := backend frontend live-data-generator
APP_START_WAIT_TIMEOUT ?= 180

GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m

help: ## Show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(GREEN)Cicada Sense$(NC)\n\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  $(YELLOW)%-26s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

install: ## Build local app images and install app dependencies inside them
	@$(COMPOSE) build $(APP_SERVICES)

setup: up ## Build and start the local stack
	@echo "$(GREEN)Application available at:$(NC)"
	@echo "  Dashboard: $(YELLOW)http://app.cicada-sense.<your base domain>$(NC)"
	@echo "  Generator: $(YELLOW)http://generator.cicada-sense.<your base domain>$(NC)"

build: ## Build local Docker images, optionally with SERVICE=<name>
	@$(COMPOSE) build $(SERVICE)

up: ## Start the local application stack
	@$(COMPOSE) up --remove-orphans --build -d --wait --wait-timeout $(APP_START_WAIT_TIMEOUT)

down: ## Stop the local application stack
	@$(COMPOSE) down --remove-orphans

logs: ## Tail local logs, optionally with SERVICE=<name>
	@if [ -n "$(SERVICE)" ]; then $(COMPOSE) logs -f $(SERVICE); else $(COMPOSE) logs -f; fi

shell: ## Open a service shell with SERVICE=<name>
	@if [ -z "$(SERVICE)" ]; then echo "$(RED)Usage: make shell SERVICE=backend$(NC)"; exit 1; fi
	@$(COMPOSE) run --rm --no-deps --remove-orphans -it $(SERVICE) sh

lint: ## Run app lint inside containers
	$(call npm-app,run lint)
	$(call run_linter)

lint-fix: ## Run app lint and fix inside containers
	$(call npm-app,run lint:fix)
	$(MAKE) linter-fix

linter-fix: ## Execute linting and fix
	$(call run_linter, \
		-e FIX_SPELL_CODESPELL=true \
		-e FIX_MARKDOWN=true \
		-e FIX_MARKDOWN_PRETTIER=true \
		-e FIX_YAML_PRETTIER=true \
		-e FIX_NATURAL_LANGUAGE=true \
		-e FIX_SHELL_SHFMT=true \
		-e FIX_BIOME_LINT=true \
		-e FIX_BIOME_FORMAT=true \
	)

define run_linter
	DEFAULT_WORKSPACE="$(CURDIR)"; \
	LINTER_IMAGE="linter:latest"; \
	VOLUME="$$DEFAULT_WORKSPACE:$$DEFAULT_WORKSPACE"; \
	docker build --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --tag $$LINTER_IMAGE .; \
	docker run \
		-e DEFAULT_WORKSPACE="$$DEFAULT_WORKSPACE" \
		-e FILTER_REGEX_INCLUDE="$(filter-out $@,$(MAKECMDGOALS))" \
		$(1) \
		-v $$VOLUME \
		--rm \
		$$LINTER_IMAGE
endef

typecheck: ## Run TypeScript checks inside containers
	$(call npm-app,run typecheck)

test: ## Run unit and integration tests inside containers
	@$(COMPOSE) up -d --wait postgres redis
	$(call npm-app, run test:ci)

helm: ## Run Helm chart checks
	@mkdir -p ./charts/dist
	@helm dependency build ./charts/application
	@helm package ./charts/application --destination ./charts/dist
	@if command -v helm-docs >/dev/null 2>&1; then helm-docs --chart-search-root ./charts; else echo "helm-docs is not installed; skipping chart docs generation"; fi
	@ct lint
	@helm dependency build ./charts/application
	@helm template cicada-sense ./charts/application --namespace cicada-sense >/dev/null

ci: build lint-fix typecheck test helm ## Run the full containerized validation suite

clean: ## Remove generated containers, volumes, and ignored local artifacts
	@$(COMPOSE) down --volumes --remove-orphans
	@rm -rf application/monitoring-workspace/backend/node_modules application/monitoring-workspace/frontend/node_modules application/live-data-generator/node_modules application/monitoring-workspace/backend/dist application/monitoring-workspace/frontend/dist application/live-data-generator/dist application/live-data-generator/dist-types node_modules charts/dist charts/application/charts/*.tgz

define npm-app
	@for service in $(APP_SERVICES); do \
		echo "$(YELLOW)$$service$(NC): npm $(1)"; \
		$(APP_RUN) $$service node-dev-entrypoint npm $(1) || exit $$?; \
	done
endef

define run_linter
	DEFAULT_WORKSPACE="$(CURDIR)"; \
	LINTER_IMAGE="linter:latest"; \
	VOLUME="$$DEFAULT_WORKSPACE:$$DEFAULT_WORKSPACE"; \
	docker build --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --tag $$LINTER_IMAGE .; \
	docker run \
		-e DEFAULT_WORKSPACE="$$DEFAULT_WORKSPACE" \
		-e FILTER_REGEX_INCLUDE="$(filter-out $@,$(MAKECMDGOALS))" \
		-e IGNORE_GITIGNORED_FILES=true \
		$(1) \
		-v $$VOLUME \
		--rm \
		$$LINTER_IMAGE
endef
