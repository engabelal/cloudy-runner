# Cloudy Runner 🚀

> A high-performance, multi-architecture Docker image packed with essential DevOps tools for modern CI/CD pipelines.

[![Docker Hub](https://img.shields.io/docker/v/engabelal/cloudy-runner?label=Docker%20Hub&sort=semver)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![Docker Image Size](https://img.shields.io/docker/image-size/engabelal/cloudy-runner/latest)](https://hub.docker.com/r/engabelal/cloudy-runner)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build & Push](https://github.com/engabelal/cloudy-runner/actions/workflows/docker-build.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/docker-build.yml)
[![Security Refresh](https://github.com/engabelal/cloudy-runner/actions/workflows/security-refresh.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/security-refresh.yml)
[![Version Checker](https://github.com/engabelal/cloudy-runner/actions/workflows/version-checker.yml/badge.svg)](https://github.com/engabelal/cloudy-runner/actions/workflows/version-checker.yml)

---

## 📖 Table of Contents

- [What is Cloudy Runner?](#what-is-cloudy-runner)
- [Supported Tools & Packages](#supported-tools--packages)
- [Why Cloudy Runner?](#why-cloudy-runner)
- [Design Approach](#design-approach)
- [Quick Start](#quick-start)
- [CI/CD Integration](#cicd-integration)
- [Version Management](#version-management)
- [Repository Structure](#repository-structure)
- [Performance](#performance)
- [Security](#security)
- [Contributing](#contributing)

---

## 🤔 What is Cloudy Runner?

Cloudy Runner is a **production-ready Docker image** that bundles all the essential DevOps tools you need for cloud-native infrastructure automation and deployments. Instead of installing tools separately in each CI/CD pipeline, use this pre-built image and start deploying immediately.

**Perfect for**:
- ✅ GitHub Actions workflows
- ✅ GitLab CI/CD pipelines
- ✅ Jenkins jobs
- ✅ Azure DevOps
- ✅ Local development environments
- ✅ Kubernetes jobs

**Key Features**:
- 🏗️ **Multi-architecture**: Native support for amd64 and arm64
- ⚡ **Optimized builds**: 70% faster rebuilds with intelligent caching
- 🔒 **Security-first**: Weekly security scans and patches
- 📦 **Version-pinned**: Reproducible builds with `versions.env`
- 🤖 **Auto-updated**: Automated version checking workflow
- 💯 **Production-ready**: Used in real-world CI/CD pipelines

---

## 📦 Supported Tools & Packages

### Infrastructure as Code (IaC)

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | 1.9.8 | Infrastructure provisioning (AWS, Azure, GCP) |
| **Ansible** | 10.7.0 | Configuration management & automation |

**Why these versions?**
- Terraform 1.9.x: Stable for production CI/CD (1.14.x too new, potential breaking changes)
- Ansible 10.x: Latest stable automation framework with Python 3.12 support

### Kubernetes Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **kubectl** | v1.31.14 | Kubernetes CLI for cluster management |
| **Helm** | v3.19.4 | Kubernetes package manager |
| **Kustomize** | v5.8.0 | Kubernetes configuration customization |

**Why these versions?**
- kubectl 1.31.x: Wide compatibility with K8s clusters (1.29-1.33)
- Helm v3.x: Most stable (v4 too bleeding-edge for CI/CD)
- Kustomize latest: Active development, stable releases

### Cloud Provider CLIs

| Tool | Version | Purpose |
|------|---------|---------|
| **AWS CLI** | Latest v2 | Amazon Web Services management |
| **Azure CLI** | Latest | Microsoft Azure management |

**Why latest?**
- Cloud CLIs are backwards compatible
- Auto-updated to get latest API features
- No breaking changes in patch releases

### Developer Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | 22.21.1 (LTS "Jod") | JavaScript runtime |
| **npm** | Bundled with Node | Package manager |
| **yarn** | Latest | Alternative package manager |
| **pnpm** | Latest | Fast, disk space efficient package manager |

**Why Node.js 22.x?**
- Latest LTS with 3+ years support
- Modern ECMAScript features
- Best performance for CI/CD tasks

### Utilities

| Tool | Version | Purpose |
|------|---------|---------|
| **yq** | v4.50.1 | YAML processor (like jq for YAML) |
| **jq** | Latest from apt | JSON processor |
| **git** | Latest from apt | Version control |
| **curl/wget** | Latest from apt | HTTP clients |
| **make** | Latest from apt | Build automation |

### Base System

| Component | Version | Purpose |
|-----------|---------|---------|
| **Ubuntu** | 24.04 LTS | Base OS (5-year support until 2029) |
| **Python** | 3.12.x | System Python (for Ansible) |
| **Build tools** | gcc, g++, make | Compile native extensions |

---

## 🎯 Why Cloudy Runner?

### The Problem

Setting up CI/CD pipelines often looks like this:

```yaml
# Every pipeline needs this boilerplate
jobs:
  deploy:
    steps:
      - run: curl -o terraform.zip ...
      - run: unzip terraform.zip
      - run: curl -o kubectl ...
      - run: curl -sL nodejs.org/setup | bash
      - run: apt-get install ansible
      # ... 20 more lines of setup
      - run: terraform apply  # Finally!
```

**Problems**:
- ⏱️ Wastes 3-5 minutes per pipeline run
- 🐛 Brittle (download failures, version mismatches)
- 🔄 Repeated across every project
- 🔐 Security risk (downloading from multiple sources)
- 📦 Hard to maintain version consistency

### The Solution

```yaml
# With Cloudy Runner
jobs:
  deploy:
    container:
      image: engabelal/cloudy-runner:latest
    steps:
      - run: terraform apply  # All tools ready!
```

**Benefits**:
- ⚡ Start deploying in seconds (not minutes)
- 🎯 Consistent tool versions across all projects
- 🔒 Security-scanned images
- 📦 Single source of truth for versions
- 🤝 Team alignment on tooling

---

## 🏗️ Design Approach

### 1. **Stability Over Bleeding Edge**

**Philosophy**: CI/CD pipelines need reliability, not latest features.

**Examples**:
- Using Terraform 1.9.x (stable) instead of 1.14.x (too new)
- Using Helm v3.x (battle-tested) instead of v4.x (beta)
- Using Node.js LTS (3-year support) not Current (6-month support)

**Result**: Fewer breaking changes, predictable behavior

### 2. **Reliability Over Raw Speed**

**Download Stage** (Dockerfile lines 38-64):
```dockerfile
# Sequential downloads for reliability
curl -fsSL -o node.tar.xz https://... &&
curl -fsSL -o terraform.zip https://... &&
curl -fsSL -o kubectl https://... &&
# Installation follows...
```

**Why sequential?** Parallel downloads with background jobs (`&`) can cause race conditions in some CI/CD environments. Sequential downloads are slightly slower but much more reliable.

### 3. **Smart Caching Without Staleness**

**Cache Strategy**:
- ✅ Cache: apt `.deb` packages (speeds up apt install)
- ✅ Cache: npm HTTP cache (speeds up yarn/pnpm install)
- ✅ Cache: pip wheels (speeds up Ansible install)
- ❌ Don't cache: apt package index (always fresh)
- ❌ Don't cache: Downloaded tool binaries (use tmpfs)

**Result**: 70% faster rebuilds + always latest security patches

See [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) for technical details.

### 4. **Security by Default**

**Weekly Automation**:
1. **Sunday 03:00 UTC**: Security refresh workflow
   - Rebuild with `--no-cache --pull`
   - Scan with Trivy (CRITICAL, HIGH, MEDIUM)
   - Upload results to GitHub Security
   - Tag as `security-latest`

2. **Monday 09:00 UTC**: Version checker workflow
   - Check for tool updates
   - Create comparison table
   - Open GitHub issue if updates available

**Manual Override**: If CVE discovered, rebuild immediately with `gh workflow run security-refresh.yml`

### 5. **Reproducible Builds**

All versions centrally managed in `versions.env`:

```bash
NODE_VERSION=22.21.1
TERRAFORM_VERSION=1.9.8
ANSIBLE_VERSION=10.7.0
# ... etc
```

**Benefits**:
- 🔍 Single file shows all versions
- 📌 Git history tracks version changes
- 🔄 Easy to rollback to previous versions
- 🤝 Team knows exactly what's installed

### 6. **Multi-Architecture Support**

**Build Process**:
- Separate Dockerfiles for amd64 and arm64
- Parallel CI/CD jobs for both architectures
- Multi-arch manifest creation
- Users pull correct architecture automatically

**Why separate Dockerfiles?**
- ARM/x64 binaries have different URLs
- Clearer than complex `if/else` logic
- Easier to debug architecture-specific issues

---

## 🚀 Quick Start

### Pull and Run

```bash
# Pull the image (auto-selects your architecture)
docker pull engabelal/cloudy-runner:latest

# Run interactively
docker run -it --rm \
  -v $(pwd):/workspace \
  engabelal/cloudy-runner:latest

# You now have access to all tools:
$ terraform version
$ kubectl version --client
$ helm version
$ node --version
```

### Check Installed Versions

```bash
docker run --rm engabelal/cloudy-runner:latest cat /etc/tool-versions.txt
```

Output:
```
=== Installed Tool Versions ===
Node.js: v22.21.1
npm: 10.9.2
yarn: 1.22.22
pnpm: 9.15.4
AWS CLI: aws-cli/2.x.x
Terraform: 1.9.8
kubectl: v1.31.14
Helm: v3.19.4
Kustomize: v5.8.0
yq: v4.50.1
Ansible: ansible [core 2.17.x]
```

---

## 🔄 CI/CD Integration

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
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          terraform init
          terraform plan
          terraform apply -auto-approve
```

### GitLab CI

```yaml
deploy:
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

### Local Development

```bash
#!/bin/bash
# deploy.sh - Local deployment script

docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws:ro \
  -v ~/.kube:/root/.kube:ro \
  -w /workspace \
  engabelal/cloudy-runner:latest \
  bash -c "
    terraform init
    terraform apply -auto-approve
    helm upgrade --install myapp ./chart
  "
```

---

## 📝 Version Management

### Understanding `versions.env`

This file is the **single source of truth** for all tool versions:

```bash
# versions.env
NODE_VERSION=22.21.1
TERRAFORM_VERSION=1.9.8
ANSIBLE_VERSION=10.7.0
KUBECTL_VERSION=v1.31.14
HELM_VERSION=v3.19.4
KUSTOMIZE_VERSION=kustomize/v5.8.0
YQ_VERSION=v4.50.1
```

**Why this approach?**
1. ✅ Clear visibility into what's installed
2. ✅ Git tracks version history
3. ✅ Easy to update all versions
4. ✅ Consistent across all architectures
5. ✅ CI/CD workflows read from same file

### How to Update Versions

#### Option 1: Manual Update (Recommended)

```bash
# 1. Edit versions.env
vim versions.env

# 2. Update desired versions
NODE_VERSION=22.22.0  # Updated
TERRAFORM_VERSION=1.9.9  # Updated

# 3. Test locally
export DOCKER_BUILDKIT=1
docker build -f Dockerfile.amd64 -t test:updated .
docker run --rm test:updated cat /etc/tool-versions.txt

# 4. Commit and push
git add versions.env
git commit -m "Update Node.js to 22.22.0, Terraform to 1.9.9"
git push

# 5. Create release tag
git tag v1.1.0
git push origin v1.1.0
# This triggers CI/CD build
```

#### Option 2: Use Version Checker Workflow

The automated weekly workflow checks for updates:

```bash
# Manually trigger version check
gh workflow run version-checker.yml

# View results
gh run list --workflow=version-checker.yml
gh run view <run-id>

# Check created issues
gh issue list --label version-update
```

The workflow creates a table like:

```markdown
| Tool | Current | Latest | Status |
|------|---------|--------|--------|
| Node.js | 22.21.1 | 22.22.0 | ⚠️ Update available |
| Terraform | 1.9.8 | 1.9.8 | ✅ Up to date |
```

### Version Strategy Guidelines

**When to update**:
- ✅ Security patches (always)
- ✅ Bug fixes (review changelog)
- ✅ Minor versions (test thoroughly)
- ⚠️ Major versions (careful evaluation needed)

**Version pinning rules**:
1. **Terraform**: Stay on 1.9.x until 1.14.x is stable
2. **Node.js**: Follow LTS releases only
3. **kubectl**: Stay on n-2 minor versions from latest K8s
4. **Helm**: Wait 2-3 months after new major version
5. **Ansible**: Update to latest minor in current major

**Testing checklist before updating**:
```bash
# 1. Build locally
docker build -f Dockerfile.amd64 -t test:new .

# 2. Verify versions
docker run --rm test:new terraform version
docker run --rm test:new node --version

# 3. Test with real project
docker run --rm -v $(pwd)/my-project:/workspace test:new \
  bash -c "cd /workspace && terraform init && terraform plan"

# 4. Check image size
docker images test:new --format "{{.Size}}"

# 5. Security scan
docker run --rm aquasec/trivy:latest image test:new
```

---

## 📂 Repository Structure

```
cloudy-runner/
├── .github/
│   └── workflows/
│       ├── docker-build.yml         # Main build pipeline (on tags)
│       ├── version-checker.yml      # Weekly version monitoring
│       └── security-refresh.yml     # Weekly security rebuild
│
├── .claude/                         # AI agent configurations
│   └── agents/
│       ├── devops-engineer.md       # DevOps best practices
│       └── deployment-engineer.md   # Deployment patterns
│
├── Dockerfile.amd64                 # x86_64 architecture build
├── Dockerfile.arm64                 # ARM64 architecture build
├── versions.env                     # Version source of truth
│
├── README.md                        # This file
├── BUILD_OPTIMIZATION.md            # Performance deep-dive
├── IMPROVEMENTS_SUMMARY.md          # Changelog
│
└── .gitignore                       # Git exclusions
```

### File Purposes

**Dockerfiles** (`Dockerfile.amd64`, `Dockerfile.arm64`):
- Define image build process
- Optimized with parallel downloads
- BuildKit cache mounts for speed
- Health checks and metadata

**versions.env**:
- Single source of truth for versions
- Read by CI/CD workflows
- Updated manually or via automation

**Workflows**:
- `docker-build.yml`: Triggered on git tags (v*)
- `version-checker.yml`: Runs Monday 09:00 UTC
- `security-refresh.yml`: Runs Sunday 03:00 UTC

**Documentation**:
- `README.md`: User guide (you're reading it!)
- `BUILD_OPTIMIZATION.md`: Technical performance details
- `IMPROVEMENTS_SUMMARY.md`: Complete changelog

---

## ⚡ Performance

### Build Times

| Scenario | Time | Details |
|----------|------|---------|
| **First build** | 5-7 min | No cache, download everything |
| **Rebuild (version update)** | 2-4 min | Cache apt/npm/pip, redownload tools |
| **Rebuild (no changes)** | ~30 sec | Full cache utilization |

### Optimizations

1. **Parallel Downloads**: All tools download simultaneously
2. **BuildKit Cache**: apt, npm, pip caches persist between builds
3. **GitHub Actions Cache**: Layer cache shared across CI runs
4. **tmpfs Downloads**: RAM-speed extraction and installation

See [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) for:
- Technical deep-dive
- Cache safety guarantees
- Benchmarking methodology
- Troubleshooting guide

---

## 🔒 Security

### Weekly Security Refresh

**Schedule**: Every Sunday at 03:00 UTC

**Process**:
1. Rebuild with `--no-cache --pull` (fresh base image)
2. Install latest tool versions from `versions.env`
3. Scan with Trivy (CRITICAL, HIGH, MEDIUM)
4. Upload SARIF to GitHub Security
5. Tag as `security-latest`
6. Create issue if vulnerabilities found

### Security Scanning

**Tools Used**:
- [Trivy](https://github.com/aquasecurity/trivy) for vulnerability scanning
- GitHub Security Code Scanning for tracking
- SARIF format for detailed reports

**Scan Levels**:
- ✅ CRITICAL: Always flagged
- ✅ HIGH: Always flagged
- ✅ MEDIUM: Monitored
- ⚠️ LOW: Informational only

### Base Image

**Ubuntu 24.04 LTS**:
- Released: April 2024
- Support until: April 2029 (5 years)
- Security updates: Automatic weekly
- Minimal attack surface: Only required packages

### Best Practices

1. **Use specific tags**: `v1.0.0` not `latest` for reproducibility
2. **Scan in your pipeline**: Add Trivy scan step
3. **Monitor Security tab**: Check GitHub Security regularly
4. **Update promptly**: Apply security patches within 7 days
5. **Read-only filesystems**: Run with `--read-only` where possible

```yaml
# Example: Security-hardened deployment
container:
  image: engabelal/cloudy-runner:v1.0.0  # Pinned version
  options: --read-only --tmpfs /tmp  # Security hardening
  env:
    TERRAFORM_CLI_ARGS: -no-color  # Disable colors for log scanning
```

---

## 🤝 Contributing

Contributions welcome! Here's how you can help:

### Report Issues

```bash
gh issue create \
  --title "Tool X version outdated" \
  --body "Current: 1.0.0, Latest: 2.0.0"
```

### Suggest Tool Additions

Open an issue with:
- Tool name and purpose
- Why it's needed for CI/CD
- Typical use cases
- Installation method

### Submit Pull Requests

```bash
# 1. Fork and clone
git clone https://github.com/YOUR-USERNAME/cloudy-runner.git

# 2. Create branch
git checkout -b feature/add-tool-x

# 3. Make changes
vim Dockerfile.amd64
vim Dockerfile.arm64
vim versions.env

# 4. Test locally
export DOCKER_BUILDKIT=1
docker build -f Dockerfile.amd64 -t test:feature .

# 5. Commit and push
git add .
git commit -m "Add Tool X v1.0.0"
git push origin feature/add-tool-x

# 6. Open PR
gh pr create --title "Add Tool X v1.0.0"
```

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

**Built with**:
- Docker BuildKit for fast builds
- GitHub Actions for CI/CD
- Trivy for security scanning
- DevOps best practices

**Inspired by**:
- HashiCorp's official Terraform image
- Google's Cloud Builder images
- GitLab Runner images
- Community feedback

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/engabelal/cloudy-runner/issues)
- **Discussions**: [GitHub Discussions](https://github.com/engabelal/cloudy-runner/discussions)
- **Email**: eng.abelal@gmail.com
- **Docker Hub**: [engabelal/cloudy-runner](https://hub.docker.com/r/engabelal/cloudy-runner)

---

**Maintained by**: Ahmed Belal
**Last Updated**: 2025-12-25
**Version**: 1.0.0
**Status**: ✅ Production Ready

---

⭐ If you find this useful, please star the repo!
