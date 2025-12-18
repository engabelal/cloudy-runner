# ------------------------------------------------------------
# Base image
# ------------------------------------------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /workspace

# ------------------------------------------------------------
# 1. Base system utilities
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
    python3-pip \
    python3-venv \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 2. Docker CLI + Buildx (official Docker repo)
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# 3. Node.js 20 LTS (official NodeSource)
# ------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g yarn pnpm \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 4. AWS CLI v2 (latest. multi-arch)
# ------------------------------------------------------------
RUN ARCH="$(dpkg --print-architecture)" \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" \
    -o awscliv2.zip \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf aws awscliv2.zip

# ------------------------------------------------------------
# 5. Azure CLI (official Microsoft installer)
# ------------------------------------------------------------
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash

# ------------------------------------------------------------
# 6. Terraform (official HashiCorp repo. latest stable)
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# 7. Python tools (latest from PyPI)
# ------------------------------------------------------------
RUN pip3 install --no-cache-dir --break-system-packages \
    ansible \
    passlib

# ------------------------------------------------------------
# 8. kubectl (latest stable. multi-arch)
# ------------------------------------------------------------
RUN ARCH="$(dpkg --print-architecture)" \
 && curl -fsSLo /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl

# ------------------------------------------------------------
# 9. Helm (latest stable. official installer)
# ------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash

# ------------------------------------------------------------
# 10. Kustomize (latest stable)
# ------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh \
    | bash \
 && mv kustomize /usr/local/bin/

# ------------------------------------------------------------
# 11. yq (latest stable. multi-arch)
# ------------------------------------------------------------
RUN ARCH="$(dpkg --print-architecture)" \
 && curl -fsSL \
    "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" \
    -o /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------
# Default command
# ------------------------------------------------------------
CMD ["/bin/bash", "-c", "echo '✅ CloudyCode Runner Ready!'"]
