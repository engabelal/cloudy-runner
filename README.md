# Cloudy Runner 🚀

> A production-ready, multi-architecture Docker image packed with essential DevOps tools for modern CI/CD pipelines.

[![Docker Hub](https://img.shields.io/docker/v/engabelal/cloudy-runner?label=Docker%20Hub&sort=semver)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![Docker Image Size](https://img.shields.io/docker/image-size/engabelal/cloudy-runner/latest)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build & Push](https://github.com/engabelal/cloudy-runner/actions/workflows/docker-build.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/docker-build.yml)
[![Security Refresh](https://github.com/engabelal/cloudy-runner/actions/workflows/security-refresh.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/security-refresh.yml)
[![Version Checker](https://github.com/engabelal/cloudy-runner/actions/workflows/version-checker.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/version-checker.yml)

## 🚀 Quick Start

```bash
# Pull and run interactively
docker run -it --rm -v $(pwd):/workspace engabelal/cloudy-runner:latest

# Check installed tools
docker run --rm engabelal/cloudy-runner:latest cat /etc/tool-versions.txt
```

## 📦 Included Tools

| Category | Tools |
|----------|-------|
| **Infrastructure** | Terraform 1.9.8, Ansible 10.7.0 |
| **Kubernetes** | kubectl v1.31.14, Helm v3.19.4, Kustomize v5.8.0 |
| **Cloud CLIs** | AWS CLI v2, Azure CLI |
| **Node.js** | Node.js 22.21.1 LTS, npm, yarn, pnpm |
| **Utilities** | yq v4.50.1, jq, git, curl, wget, make |
| **Base** | Ubuntu 24.04 LTS, Python 3.12 |

> All versions are pinned in [`versions.env`](versions.env) for reproducibility.

## 🔄 CI/CD Integration

<details>
<summary><b>GitHub Actions</b></summary>

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: engabelal/cloudy-runner:latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform init && terraform apply -auto-approve
```
</details>

<details>
<summary><b>GitLab CI</b></summary>

```yaml
deploy:
  image: engabelal/cloudy-runner:latest
  script:
    - terraform init
    - terraform apply -auto-approve
```
</details>

<details>
<summary><b>Jenkins</b></summary>

```groovy
pipeline {
    agent {
        docker { image 'engabelal/cloudy-runner:latest' }
    }
    stages {
        stage('Deploy') {
            steps { sh 'terraform apply -auto-approve' }
        }
    }
}
```
</details>

<details>
<summary><b>Local Development</b></summary>

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws:ro \
  -w /workspace \
  engabelal/cloudy-runner:latest \
  terraform apply
```
</details>

> 📂 More examples in the [`examples/`](examples/) directory.

## 🏗️ Repository Structure

```
cloudy-runner/
├── .github/
│   ├── workflows/
│   │   ├── docker-build.yml       # Multi-arch image builds
│   │   ├── security-refresh.yml   # Weekly security scans
│   │   └── version-checker.yml    # Tool update monitoring
│   ├── dependabot.yml             # Dependency updates
│   └── labels.yml                 # Issue label definitions
├── docs/
│   ├── BUILD_OPTIMIZATION.md      # Performance & caching docs
│   ├── CHANGELOG.md               # Version history
│   └── SECURITY.md                # Vulnerability reporting
├── examples/
│   ├── github-actions/            # GitHub Actions examples
│   ├── gitlab-ci/                 # GitLab CI examples
│   └── local-dev/                 # Local development scripts
├── Dockerfile.amd64               # x86_64 build
├── Dockerfile.arm64               # ARM64 build (Apple Silicon, Graviton)
├── versions.env                   # Tool versions (single source of truth)
├── Makefile                       # Build automation commands
├── LICENSE                        # MIT License
└── README.md                      # This file
```

### Workflows

| Workflow | Schedule | Purpose |
|----------|----------|---------|
| `docker-build.yml` | On tags (`v*`) | Build & push multi-arch images |
| `security-refresh.yml` | Sunday 03:00 UTC | Rebuild with security patches + Trivy scan |
| `version-checker.yml` | Monday 09:00 UTC | Check for tool updates |

## 🔒 Security

- **Weekly scans**: Trivy vulnerability scanning
- **Fresh base image**: Ubuntu 24.04 LTS pulled weekly
- **Version pinning**: All tools version-locked
- **Security policy**: See [SECURITY.md](docs/SECURITY.md)

### Scan the image yourself:
```bash
docker run --rm aquasec/trivy:latest image engabelal/cloudy-runner:latest
```

## ⚡ Performance

| Scenario | Build Time |
|----------|-----------|
| Fresh build | ~5-7 min |
| Cached rebuild | ~2-4 min |
| No changes | ~30 sec |

**Optimizations**:
- BuildKit cache mounts (apt, npm, pip)
- tmpfs for downloads
- GitHub Actions layer caching
- Native ARM runners (no QEMU emulation)

> Details in [BUILD_OPTIMIZATION.md](docs/BUILD_OPTIMIZATION.md)

## 📝 Version Management

```bash
# Update tool versions
vim versions.env

# Test locally
docker build -f Dockerfile.amd64 -t test:new .

# Release
git tag v1.1.0 && git push origin v1.1.0
```

The weekly **Version Checker** workflow automatically creates issues when updates are available.

## 🤝 Contributing

1. Fork the repo
2. Edit `Dockerfile.amd64`, `Dockerfile.arm64`, and `versions.env`
3. Test locally with `docker build`
4. Submit a PR

See [CHANGELOG.md](docs/CHANGELOG.md) for version history.

## 📞 Links

| Resource | Link |
|----------|------|
| Docker Hub | [engabelal/cloudy-runner](https://hub.docker.com/r/engabelal/cloudy-runner) |
| GitHub | [engabelal/cloudy-runner](https://github.com/engabelal/cloudy-runner) |
| Issues | [Report a bug](https://github.com/engabelal/cloudy-runner/issues) |
| Security | [SECURITY.md](docs/SECURITY.md) |

---

**Maintained by**: Ahmed Belal • **License**: MIT • **Status**: ✅ Production Ready

⭐ Star this repo if you find it useful!
