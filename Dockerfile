# ============================================================
# CI Runner Image
# Versions are injected via build arguments
# Multi-arch safe (amd64 / arm64)
# ============================================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# ------------------------------------------------------------
# Build arguments (from versions.env)
# ------------------------------------------------------------
ARG NODE_VERSION
ARG AWSCLI_VERSION
ARG TERRAFORM_VERSION
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG KUSTOMIZE_VERSION
ARG YQ_VERSION
ARG ANSIBLE_VERSION

# Provided automatically by Buildx
ARG TARGETARCH

# ------------------------------------------------------------
# Core system utilities
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    gnupg \
    lsb-release \
    software-properties-common \
    make \
    build-essential \
    python3 \
    python3-venv \
    python3-pip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Docker CLI + Buildx
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
# Node.js (multi-arch)
# ------------------------------------------------------------
RUN curl -fsSL \
    https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${TARGETARCH}.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1 \
    && npm install -g yarn pnpm

# ------------------------------------------------------------
# AWS CLI v2 (multi-arch)
# ------------------------------------------------------------
RUN curl -fsSL \
    https://awscli.amazonaws.com/awscli-exe-linux-${TARGETARCH}-${AWSCLI_VERSION}.zip \
    -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# ------------------------------------------------------------
# Terraform (multi-arch)
# ------------------------------------------------------------
RUN curl -fsSL \
    https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip \
    -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && rm terraform.zip

# ------------------------------------------------------------
# Kubernetes tools
# ------------------------------------------------------------
# kubectl (already multi-arch)
RUN curl -fsSL \
    https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# helm (multi-arch)
RUN curl -fsSL \
    https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    | tar -xz \
    && mv linux-${TARGETARCH}/helm /usr/local/bin/helm \
    && rm -rf linux-${TARGETARCH}

# kustomize (FIXED: multi-arch safe)
RUN curl -fsSL \
    https://github.com/kubernetes-sigs/kustomize/releases/download/${KUSTOMIZE_VERSION}/kustomize_linux_${TARGETARCH}.tar.gz \
    | tar -xz \
    && mv kustomize /usr/local/bin/kustomize

# yq (multi-arch)
RUN curl -fsSL \
    https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH} \
    -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# ------------------------------------------------------------
# Ansible (isolated venv)
# ------------------------------------------------------------
RUN python3 -m venv /opt/ansible \
    && /opt/ansible/bin/pip install --no-cache-dir \
       ansible==${ANSIBLE_VERSION} passlib

ENV PATH="/opt/ansible/bin:${PATH}"

# ------------------------------------------------------------
# Final cleanup
# ------------------------------------------------------------
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

WORKDIR /workspace
CMD ["/bin/bash"]
