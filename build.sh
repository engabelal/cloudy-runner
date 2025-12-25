#!/usr/bin/env bash
set -euo pipefail

set -a
source ./versions.env
set +a

docker build \
  --pull \
  --build-arg NODE_VERSION \
  --build-arg AWSCLI_VERSION \
  --build-arg TERRAFORM_VERSION \
  --build-arg KUBECTL_VERSION \
  --build-arg HELM_VERSION \
  --build-arg KUSTOMIZE_VERSION \
  --build-arg YQ_VERSION \
  --build-arg ANSIBLE_VERSION \
  -t cloudycode/ci-runner:latest .
