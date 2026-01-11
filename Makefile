.PHONY: help install validate build build-html build-pdf serve clean docker-build docker-up docker-down docker-logs docker-shell test deploy-local

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Resume Makefile Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install dependencies (resume-cli)
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm install -g resume-cli
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

validate: ## Validate resume.json
	@echo "$(BLUE)Validating resume.json...$(NC)"
	resume validate resume.json
	@echo "$(GREEN)✓ Resume is valid$(NC)"

build-html: validate ## Build HTML version
	@echo "$(BLUE)Building HTML...$(NC)"
	resume export resume.html --resume resume.json
	@echo "$(GREEN)✓ HTML created: resume.html$(NC)"

build-pdf: validate ## Build PDF version
	@echo "$(BLUE)Building PDF...$(NC)"