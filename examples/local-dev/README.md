# Local Development Examples

Scripts for using Cloudy Runner in local development.

## deploy.sh

Interactive deployment script:

```bash
#!/bin/bash
# deploy.sh - Run Cloudy Runner locally

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check for required credentials
check_credentials() {
    if [[ ! -d "$HOME/.aws" ]]; then
        echo -e "${RED}Error: ~/.aws not found. Run 'aws configure' first.${NC}"
        exit 1
    fi
}

# Run Cloudy Runner container
run_container() {
    docker run -it --rm \
        -v "$(pwd):/workspace" \
        -v "$HOME/.aws:/root/.aws:ro" \
        -v "$HOME/.kube:/root/.kube:ro" \
        -w /workspace \
        engabelal/cloudy-runner:latest \
        "$@"
}

# Main
check_credentials

if [[ $# -eq 0 ]]; then
    echo -e "${GREEN}Starting interactive shell...${NC}"
    run_container bash
else
    run_container "$@"
fi
```

## Makefile

Local development shortcuts:

```makefile
.PHONY: shell terraform ansible

IMAGE := engabelal/cloudy-runner:latest

# Start interactive shell
shell:
	docker run -it --rm \
		-v $(PWD):/workspace \
		-v $(HOME)/.aws:/root/.aws:ro \
		-w /workspace \
		$(IMAGE) bash

# Run Terraform commands
terraform:
	docker run --rm \
		-v $(PWD):/workspace \
		-v $(HOME)/.aws:/root/.aws:ro \
		-w /workspace \
		$(IMAGE) terraform $(ARGS)

# Run Ansible playbook
ansible:
	docker run --rm \
		-v $(PWD):/workspace \
		-v $(HOME)/.ssh:/root/.ssh:ro \
		-w /workspace \
		$(IMAGE) ansible-playbook $(ARGS)
```

## Usage

```bash
# Start interactive shell
./deploy.sh

# Run specific command
./deploy.sh terraform plan

# Using Makefile
make shell
make terraform ARGS="plan"
make ansible ARGS="playbook.yml -i inventory"
```
