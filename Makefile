PYTHON         ?= python3
VENV           ?= venv
VENV_BIN        = $(VENV)/bin
PIP             = $(VENV_BIN)/pip
UVICORN         = $(VENV_BIN)/uvicorn
REQUIREMENTS    = backend/requirements.txt
APP_MODULE      = backend.app.main:app
HOST           ?= 127.0.0.1
PORT           ?= 8000
DOCKER          = docker
DOCKER_COMPOSE  = $(DOCKER) compose
SYS_DEPS        = libpq-dev python3-dev build-essential

.PHONY: install run docker clean alembic migration_alembic_users_table

install:
	@if [ ! -d "$(VENV)" ]; then \
		echo "Création de l'environnement virtuel avec $(PYTHON)..."; \
		$(PYTHON) -m venv $(VENV); \
	fi
	@echo "Mise à jour de pip..."
	@$(PIP) install --upgrade pip
	@if command -v apt-get > /dev/null 2>&1; then \
		if ! dpkg -l $(SYS_DEPS) > /dev/null 2>&1; then \
			echo "Installation des dépendances système ($(SYS_DEPS))..."; \
			sudo apt-get update && sudo apt-get install -y $(SYS_DEPS); \
		fi \
	fi
	@if [ -f "$(REQUIREMENTS)" ]; then \
		echo "Installation des dépendances depuis $(REQUIREMENTS)..."; \
		$(PIP) install -r $(REQUIREMENTS); \
	else \
		echo "Erreur : Le fichier $(REQUIREMENTS) est introuvable."; \
		exit 1; \
	fi

run:
	@if [ ! -f "$(UVICORN)" ]; then \
		echo "Uvicorn est absent de $(VENV). Tentative d'installation automatique..."; \
		$(PIP) install uvicorn; \
	fi
	@echo "Lancement de l'application sur http://$(HOST):$(PORT)..."
	@$(UVICORN) $(APP_MODULE) --reload --host $(HOST) --port $(PORT)

docker:
	@if ! command -v $(DOCKER) > /dev/null 2>&1; then \
		echo "Erreur : $(DOCKER) n'est pas installé sur ce système."; \
		exit 1; \
	fi
	@if ! $(DOCKER) info > /dev/null 2>&1; then \
		echo "Erreur : Le service Docker n'est pas démarré ou l'utilisateur courant n'a pas les permissions."; \
		exit 1; \
	fi
	@echo "Lancement des conteneurs avec Docker Compose..."
	@$(DOCKER_COMPOSE) up -d
	@$(DOCKER_COMPOSE) ps

clean:
	@echo "Suppression des fichiers caches..."
	@find . -type d -name "__pycache__" -exec rm -rf {} +

alembic:
	@$(VENV_BIN)/alembic init backend/alembic

migration_alembic_users_table:
	alembic revision --autogenerate -m "create users table"
	alembic upgrade head
