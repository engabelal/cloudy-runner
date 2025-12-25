# Cloudy Runner

Multi-architecture CI/CD runner image packed with essential DevOps tools for cloud-native deployments.

[![Docker Hub](https://img.shields.io/docker/v/engabelal/cloudy-runner?label=Docker%20Hub&sort=semver)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![Docker Image Size](https://img.shields.io/docker/image-size/engabelal/cloudy-runner/latest)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Features

- **Multi-Architecture Support**: Native builds for `amd64` and `arm64`
- **Cloud CLI Tools**: AWS CLI v2, Azure CLI
- **Infrastructure as Code**: Terraform, Ansible
- **Kubernetes**: kubectl, Helm, Kustomize
- **Node.js Ecosystem**: Node.js LTS, npm, yarn, pnpm
- **Utilities**: yq, jq, git, make, and more
- **Production Ready**: Optimized for CI/CD pipelines with health checks

## 📦 Installed Tools

| Tool | Version | Description |
|------|---------|-------------|
| Node.js | 22.21.1 | JavaScript runtime (LTS "Jod") |
| Terraform | 1.9.8 | Infrastructure as Code |
| Ansible | 10.7.0 | Configuration management |
| kubectl | v1.31.14 | Kubernetes CLI |
| Helm | v3.19.4 | Kubernetes package manager |
| Kustomize | v5.8.0 | Kubernetes configuration customization |
| yq | v4.50.1 | YAML processor |
| AWS CLI | Latest | Amazon Web Services CLI |
| Azure CLI | Latest | Microsoft Azure CLI |

## 🎯 Usage

### Pull the Image

```bash
# Pull latest multi-arch image (auto-selects your architecture)
docker pull engabelal/cloudy-runner:latest

# Pull specific architecture
docker pull engabelal/cloudy-runner:amd64
docker pull engabelal/cloudy-runner:arm64

# Pull specific version
docker pull engabelal/cloudy-runner:v1.0.0
```

### Run Interactively

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  engabelal/cloudy-runner:latest
```

### Check Installed Versions

```bash
docker run --rm engabelal/cloudy-runner:latest cat /etc/tool-versions.txt
```

## 🔧 CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest

    steps:
      - uses: actions/checkout@v4

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        run: terraform apply -auto-approve
        if: github.ref == 'refs/heads/main'
```

### GitLab CI

```yaml
terraform:
  image: engabelal/cloudy-runner:latest
  script:
    - terraform init
    - terraform plan
    - terraform apply -auto-approve
  only:
    - main
```

### Jenkins Pipeline

```groovy
pipeline {
    agent {
        docker {
            image 'engabelal/cloudy-runner:latest'
            args '-v $HOME/.aws:/root/.aws:ro'
        }
    }
    stages {
        stage('Deploy') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
```

## 💡 Common Use Cases

### Terraform Deployment

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_DEFAULT_REGION \
  engabelal/cloudy-runner:latest \
  terraform apply -auto-approve
```

### Kubernetes Deployment with Helm

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.kube:/root/.kube:ro \
  -w /workspace \
  engabelal/cloudy-runner:latest \
  helm upgrade --install myapp ./chart --namespace production
```

### Ansible Playbook Execution

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.ssh:/root/.ssh:ro \
  -w /workspace \
  engabelal/cloudy-runner:latest \
  ansible-playbook -i inventory playbook.yml
```

### Multi-Tool Pipeline

```bash
#!/bin/bash
# Build, test, and deploy script

docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws:ro \
  -v ~/.kube:/root/.kube:ro \
  -w /workspace \
  engabelal/cloudy-runner:latest \
  bash -c "
    echo '==> Installing dependencies'
    npm ci

    echo '==> Running tests'
    npm test

    echo '==> Building application'
    npm run build

    echo '==> Deploying infrastructure'
    cd terraform && terraform apply -auto-approve

    echo '==> Deploying application'
    cd .. && helm upgrade --install myapp ./chart
  "
```

## 🏗️ Building from Source

```bash
# Clone the repository
git clone https://github.com/engabelal/cloudy-runner.git
cd cloudy-runner

# Build for your architecture
docker build -f Dockerfile.amd64 -t cloudy-runner:local .

# Or use docker buildx for multi-arch
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t cloudy-runner:multi-arch \
  --load \
  .
```

## 🔐 Security

- Base image: Ubuntu 24.04 LTS
- Regular security updates
- Minimal attack surface
- No unnecessary packages
- Health checks included

## 📝 Version Management

All tool versions are centrally managed in `versions.env`. To customize:

```bash
# Edit versions.env
NODE_VERSION=22.21.1
TERRAFORM_VERSION=1.9.8
# ... etc

# Build with custom versions
docker build \
  -f Dockerfile.amd64 \
  --build-arg NODE_VERSION=22.21.1 \
  --build-arg TERRAFORM_VERSION=1.9.8 \
  -t my-custom-runner:latest \
  .
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built for DevOps engineers who value automation, consistency, and reliability in CI/CD pipelines.

---

**Maintained by**: Ahmed Belal (eng.abelal@gmail.com)
**Docker Hub**: [engabelal/cloudy-runner](https://hub.docker.com/r/engabelal/cloudy-runner)
