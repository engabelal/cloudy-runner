.PHONY: help build build-amd64 build-arm64 test run shell clean version scan push-latest

# Variables
IMAGE_NAME ?= cloudy-runner
REGISTRY ?= engabelal
TAG ?= local
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(TAG)

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

help: ## Show this help message
	@echo '$(GREEN)Cloudy Runner - Makefile Commands$(RESET)'
	@echo ''
	@echo 'Usage:'
	@echo '  make $(YELLOW)<target>$(RESET)'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Examples:'
	@echo '  make build-amd64            # Build amd64 image'
	@echo '  make test                   # Test built image'
	@echo '  make run                    # Run interactive shell'
	@echo '  make scan                   # Security scan'

load-versions: ## Load versions from versions.env
	@echo "$(GREEN)Loading versions from versions.env...$(RESET)"
	@set -a && . ./versions.env && set +a

build-amd64: load-versions ## Build amd64 image
	@echo "$(GREEN)Building amd64 image...$(RESET)"
	@export DOCKER_BUILDKIT=1 && \
	set -a && . ./versions.env && set +a && \
	docker build \
		-f Dockerfile.amd64 \
		--build-arg NODE_VERSION=$$NODE_VERSION \
		--build-arg TERRAFORM_VERSION=$$TERRAFORM_VERSION \
		--build-arg ANSIBLE_VERSION=$$ANSIBLE_VERSION \
		--build-arg KUBECTL_VERSION=$$KUBECTL_VERSION \
		--build-arg HELM_VERSION=$$HELM_VERSION \
		--build-arg KUSTOMIZE_VERSION=$$KUSTOMIZE_VERSION \
		--build-arg YQ_VERSION=$$YQ_VERSION \
		-t $(FULL_IMAGE)-amd64 \
		.
	@echo "$(GREEN)✅ Build complete: $(FULL_IMAGE)-amd64$(RESET)"

build-arm64: load-versions ## Build arm64 image
	@echo "$(GREEN)Building arm64 image...$(RESET)"
	@export DOCKER_BUILDKIT=1 && \
	set -a && . ./versions.env && set +a && \
	docker build \
		-f Dockerfile.arm64 \
		--build-arg NODE_VERSION=$$NODE_VERSION \
		--build-arg TERRAFORM_VERSION=$$TERRAFORM_VERSION \
		--build-arg ANSIBLE_VERSION=$$ANSIBLE_VERSION \
		--build-arg KUBECTL_VERSION=$$KUBECTL_VERSION \
		--build-arg HELM_VERSION=$$HELM_VERSION \
		--build-arg KUSTOMIZE_VERSION=$$KUSTOMIZE_VERSION \
		--build-arg YQ_VERSION=$$YQ_VERSION \
		-t $(FULL_IMAGE)-arm64 \
		.
	@echo "$(GREEN)✅ Build complete: $(FULL_IMAGE)-arm64$(RESET)"

build: ## Build image for current architecture
	@echo "$(GREEN)Detecting architecture...$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		$(MAKE) build-amd64; \
	elif [ "$$ARCH" = "aarch64" ] || [ "$$ARCH" = "arm64" ]; then \
		$(MAKE) build-arm64; \
	else \
		echo "$(YELLOW)⚠️  Unsupported architecture: $$ARCH$(RESET)"; \
		exit 1; \
	fi

test: ## Test the built image
	@echo "$(GREEN)Testing image: $(FULL_IMAGE)$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		IMAGE="$(FULL_IMAGE)-amd64"; \
	else \
		IMAGE="$(FULL_IMAGE)-arm64"; \
	fi; \
	echo "$(YELLOW)Checking installed versions...$(RESET)" && \
	docker run --rm $$IMAGE cat /etc/tool-versions.txt && \
	echo "" && \
	echo "$(YELLOW)Testing Terraform...$(RESET)" && \
	docker run --rm $$IMAGE terraform version && \
	echo "$(YELLOW)Testing kubectl...$(RESET)" && \
	docker run --rm $$IMAGE kubectl version --client && \
	echo "$(YELLOW)Testing Helm...$(RESET)" && \
	docker run --rm $$IMAGE helm version --short && \
	echo "$(YELLOW)Testing Node.js...$(RESET)" && \
	docker run --rm $$IMAGE node --version && \
	echo "" && \
	echo "$(GREEN)✅ All tests passed!$(RESET)"

run: ## Run interactive shell in container
	@echo "$(GREEN)Starting interactive shell...$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		IMAGE="$(FULL_IMAGE)-amd64"; \
	else \
		IMAGE="$(FULL_IMAGE)-arm64"; \
	fi; \
	docker run -it --rm \
		-v $$(pwd):/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-w /workspace \
		$$IMAGE /bin/bash

shell: run ## Alias for 'run'

version: ## Show installed tool versions
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		IMAGE="$(FULL_IMAGE)-amd64"; \
	else \
		IMAGE="$(FULL_IMAGE)-arm64"; \
	fi; \
	docker run --rm $$IMAGE cat /etc/tool-versions.txt

scan: ## Security scan with Trivy
	@echo "$(GREEN)Running security scan...$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		IMAGE="$(FULL_IMAGE)-amd64"; \
	else \
		IMAGE="$(FULL_IMAGE)-arm64"; \
	fi; \
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image \
		--severity HIGH,CRITICAL \
		$$IMAGE

scan-full: ## Full security scan with all severities
	@echo "$(GREEN)Running full security scan...$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		IMAGE="$(FULL_IMAGE)-amd64"; \
	else \
		IMAGE="$(FULL_IMAGE)-arm64"; \
	fi; \
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image \
		$$IMAGE

push-latest: ## Push image to Docker Hub as latest
	@echo "$(GREEN)Pushing image to Docker Hub...$(RESET)"
	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		docker push $(FULL_IMAGE)-amd64; \
	else \
		docker push $(FULL_IMAGE)-arm64; \
	fi
	@echo "$(GREEN)✅ Push complete!$(RESET)"

clean: ## Remove built images
	@echo "$(YELLOW)Removing local images...$(RESET)"
	@docker rmi $(FULL_IMAGE)-amd64 2>/dev/null || true
	@docker rmi $(FULL_IMAGE)-arm64 2>/dev/null || true
	@echo "$(GREEN)✅ Clean complete!$(RESET)"

clean-all: clean ## Remove all images including pulled ones
	@echo "$(YELLOW)Removing all cloudy-runner images...$(RESET)"
	@docker images | grep cloudy-runner | awk '{print $$3}' | xargs docker rmi -f 2>/dev/null || true
	@echo "$(GREEN)✅ Deep clean complete!$(RESET)"

.DEFAULT_GOAL := help
