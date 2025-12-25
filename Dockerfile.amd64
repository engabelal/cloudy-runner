# ============================================================
# CI Runner Image. Latest at build time. Multi arch (amd64, arm64)
# ============================================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Buildx provides this automatically
ARG TARGETARCH

# Optional. Avoid GitHub API rate limits in CI
ARG GITHUB_TOKEN

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# ------------------------------------------------------------
# Base utilities
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git jq unzip zip gnupg lsb-release \
    software-properties-common make build-essential \
    python3 python3-venv python3-pip \
    xz-utils tar \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Docker CLI + Buildx plugin
# ------------------------------------------------------------
RUN install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
     | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
     https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
     > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-ce-cli docker-buildx-plugin \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Helpers. GitHub API headers
# ------------------------------------------------------------
RUN cat >/usr/local/bin/gh_api_get <<'EOF' \
  && chmod +x /usr/local/bin/gh_api_get
#!/usr/bin/env bash
set -euo pipefail
url="$1"
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "$url"
else
  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    "$url"
fi
EOF

# ------------------------------------------------------------
# Node.js. Latest LTS from dist/index.json. With SHA256 verify
# Node arch naming: amd64=>x64. arm64=>arm64
# ------------------------------------------------------------
RUN if [[ "${TARGETARCH}" == "amd64" ]]; then NODE_ARCH="x64"; \
    elif [[ "${TARGETARCH}" == "arm64" ]]; then NODE_ARCH="arm64"; \
    else echo "Unsupported TARGETARCH=${TARGETARCH}" && exit 1; fi \
  && NODE_VER="$(curl -fsSL https://nodejs.org/dist/index.json \
      | jq -r '[.[] | select(.lts != false)] | .[0].version')" \
  && NODE_VER_NO_V="${NODE_VER#v}" \
  && NODE_TGZ="node-v${NODE_VER_NO_V}-linux-${NODE_ARCH}.tar.xz" \
  && curl -fsSL "https://nodejs.org/dist/${NODE_VER}/${NODE_TGZ}" -o "/tmp/${NODE_TGZ}" \
  && curl -fsSL "https://nodejs.org/dist/${NODE_VER}/SHASUMS256.txt" -o /tmp/SHASUMS256.txt \
  && grep " ${NODE_TGZ}$" /tmp/SHASUMS256.txt | sha256sum -c - \
  && tar -xJ -f "/tmp/${NODE_TGZ}" -C /usr/local --strip-components=1 \
  && rm -f "/tmp/${NODE_TGZ}" /tmp/SHASUMS256.txt \
  && npm install -g yarn pnpm

# ------------------------------------------------------------
# AWS CLI v2. Latest. Correct official URLs. Multi arch mapping
# Docker: amd64|arm64. AWS: x86_64|aarch64
# ------------------------------------------------------------
RUN if [[ "${TARGETARCH}" == "amd64" ]]; then AWS_ARCH="x86_64"; \
    elif [[ "${TARGETARCH}" == "arm64" ]]; then AWS_ARCH="aarch64"; \
    else echo "Unsupported TARGETARCH=${TARGETARCH}" && exit 1; fi \
  && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip \
  && unzip /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /tmp/aws /tmp/awscliv2.zip

# ------------------------------------------------------------
# Terraform. Latest stable from GitHub releases list
# Pull first non prerelease. Then pick correct linux_${TARGETARCH}.zip asset
# ------------------------------------------------------------
RUN TF_JSON="$(gh_api_get https://api.github.com/repos/hashicorp/terraform/releases)" \
  && TF_TAG="$(echo "${TF_JSON}" | jq -r '[.[] | select(.prerelease==false and .draft==false)][0].tag_name')" \
  && TF_REL="$(gh_api_get "https://api.github.com/repos/hashicorp/terraform/releases/tags/${TF_TAG}")" \
  && TF_URL="$(echo "${TF_REL}" | jq -r --arg arch "${TARGETARCH}" \
      '.assets[]
       | select(.name | test("^terraform_.*_linux_"+$arch+"\\.zip$"))
       | .browser_download_url' | head -n1)" \
  && [[ -n "${TF_URL}" ]] \
  && curl -fsSL "${TF_URL}" -o /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip

# ------------------------------------------------------------
# kubectl. Latest stable from stable.txt. With SHA256 verify
# ------------------------------------------------------------
RUN KUBECTL_VER="$(curl -fsSL https://dl.k8s.io/release/stable.txt)" \
  && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/${TARGETARCH}/kubectl" -o /usr/local/bin/kubectl \
  && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/${TARGETARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
  && echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c - \
  && chmod +x /usr/local/bin/kubectl \
  && rm -f /tmp/kubectl.sha256

# ------------------------------------------------------------
# Helm. Latest from GitHub releases latest. Pick linux-${TARGETARCH}.tar.gz
# ------------------------------------------------------------
RUN HELM_REL="$(gh_api_get https://api.github.com/repos/helm/helm/releases/latest)" \
  && HELM_URL="$(echo "${HELM_REL}" | jq -r --arg arch "${TARGETARCH}" \
      '.assets[]
       | select(.name | test("^helm-.*-linux-"+$arch+"\\.tar\\.gz$"))
       | .browser_download_url' | head -n1)" \
  && [[ -n "${HELM_URL}" ]] \
  && curl -fsSL "${HELM_URL}" -o /tmp/helm.tgz \
  && tar -xzf /tmp/helm.tgz -C /tmp \
  && mv "/tmp/linux-${TARGETARCH}/helm" /usr/local/bin/helm \
  && rm -rf /tmp/helm.tgz "/tmp/linux-${TARGETARCH}"

# ------------------------------------------------------------
# Kustomize. Latest from GitHub releases latest. Asset name differs across versions
# We select any tar.gz that contains linux_${TARGETARCH} and starts with kustomize
# ------------------------------------------------------------
RUN KUS_REL="$(gh_api_get https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest)" \
  && KUS_URL="$(echo "${KUS_REL}" | jq -r --arg arch "${TARGETARCH}" \
      '.assets[]
       | select(.name | test("^kustomize.*linux_"+$arch+".*\\.tar\\.gz$"))
       | .browser_download_url' | head -n1)" \
  && [[ -n "${KUS_URL}" ]] \
  && curl -fsSL "${KUS_URL}" -o /tmp/kustomize.tgz \
  && tar -xzf /tmp/kustomize.tgz -C /tmp \
  && mv /tmp/kustomize /usr/local/bin/kustomize \
  && chmod +x /usr/local/bin/kustomize \
  && rm -f /tmp/kustomize.tgz

# ------------------------------------------------------------
# yq. Latest from GitHub releases latest. Asset yq_linux_${TARGETARCH}
# ------------------------------------------------------------
RUN YQ_REL="$(gh_api_get https://api.github.com/repos/mikefarah/yq/releases/latest)" \
  && YQ_URL="$(echo "${YQ_REL}" | jq -r --arg arch "${TARGETARCH}" \
      '.assets[]
       | select(.name == ("yq_linux_"+$arch))
       | .browser_download_url' | head -n1)" \
  && [[ -n "${YQ_URL}" ]] \
  && curl -fsSL "${YQ_URL}" -o /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq

# ------------------------------------------------------------
# Azure CLI. Latest from Microsoft install script
# ------------------------------------------------------------
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

# ------------------------------------------------------------
# Ansible. Latest from pip. Isolated venv
# ------------------------------------------------------------
RUN python3 -m venv /opt/ansible \
  && /opt/ansible/bin/pip install --no-cache-dir ansible passlib
ENV PATH="/opt/ansible/bin:${PATH}"

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

WORKDIR /workspace
CMD ["/bin/bash"]