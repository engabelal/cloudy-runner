# ============================================================
# Base
# ============================================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /workspace

# ============================================================
# 1. Base system utilities
# ============================================================
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
    python3-pip \
    python3-venv \
 && rm -rf /var/lib/apt/lists/*

# ============================================================
# 2. Docker CLI + Buildx
# ============================================================
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y docker-ce-cli docker-buildx-plugin \
 && rm -rf /var/lib/apt/lists/*

# ============================================================
# 3. Node.js 20 LTS
# ============================================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g yarn pnpm \
 && rm -rf /var/lib/apt/lists/*

# ============================================================
# 4. AWS CLI v2 (CORRECT multi-arch)
# ============================================================
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
      amd64) AWS_ARCH="x86_64" ;; \
      arm64) AWS_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
      -o awscliv2.zip; \
    unzip awscliv2.zip; \
    ./aws/install; \
    rm -rf aws awscliv2.zip

# ============================================================
# 5. Azure CLI
# ============================================================
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

# ============================================================
# 6. Terraform (official repo)
# ============================================================
RUN wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com \
    $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update \
 && apt-get install -y terraform \
 && rm -rf /var/lib/apt/lists/*

# ============================================================
# 7. Python tools
# ============================================================
RUN pip3 install --no-cache-dir --break-system-packages \
    ansible \
    passlib

# ============================================================
# 8. kubectl (FINAL FIX. multi-arch safe)
# ============================================================
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
      amd64) K8S_ARCH="amd64" ;; \
      arm64) K8S_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    curl -fsSLo /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${K8S_ARCH}/kubectl"; \
    chmod +x /usr/local/bin/kubectl

# ============================================================
# 9. Helm (latest stable, official installer)
# ============================================================
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash

# ============================================================
# 10. Kustomize
# ============================================================
RUN curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh \
    | bash \
 && mv kustomize /usr/local/bin/

# ============================================================
# 11. yq (multi-arch safe)
# ============================================================
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
      amd64) YQ_ARCH="amd64" ;; \
      arm64) YQ_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    curl -fsSL \
      "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH}" \
      -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

# ============================================================
# Cleanup
# ============================================================
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ============================================================
# Default
# ============================================================
CMD ["/bin/bash", "-c", "echo '✅ CloudyCode Runner Ready!'"]
